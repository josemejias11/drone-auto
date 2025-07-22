import Foundation
import UIKit

/// Service for managing mission files in the Files app
class MissionFileManager {
    
    static let shared = MissionFileManager()
    
    private let documentsDirectory: URL
    private let missionsSubdirectory = "DroneAutoMissions"
    private let fileExtension = "json"
    
    private init() {
        // Get the Documents directory (accessible in Files app)
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, 
                                                     in: .userDomainMask).first!
        
        // Create missions subdirectory if it doesn't exist
        let missionsURL = documentsDirectory.appendingPathComponent(missionsSubdirectory)
        try? FileManager.default.createDirectory(at: missionsURL, 
                                               withIntermediateDirectories: true, 
                                               attributes: nil)
    }
    
    // MARK: - File Operations
    
    /// Save a mission to Files app
    func saveMission(_ mission: JSONMission, completion: @escaping (Result<URL, Error>) -> Void) {
        let fileName = sanitizeFileName(mission.metadata.name) + "." + fileExtension
        let fileURL = getMissionsDirectory().appendingPathComponent(fileName)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            
            let jsonData = try encoder.encode(mission)
            try jsonData.write(to: fileURL)
            
            DispatchQueue.main.async {
                completion(.success(fileURL))
            }
            
            Logger.shared.info("Mission saved successfully: \(fileName)")
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            Logger.shared.error("Failed to save mission: \(error.localizedDescription)")
        }
    }
    
    /// Load a mission from Files app
    func loadMission(from url: URL, completion: @escaping (Result<JSONMission, Error>) -> Void) {
        do {
            let jsonData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let mission = try decoder.decode(JSONMission.self, from: jsonData)
            
            DispatchQueue.main.async {
                completion(.success(mission))
            }
            
            Logger.shared.info("Mission loaded successfully: \(url.lastPathComponent)")
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            Logger.shared.error("Failed to load mission: \(error.localizedDescription)")
        }
    }
    
    /// List all saved missions
    func listSavedMissions() -> [MissionFileInfo] {
        let missionsURL = getMissionsDirectory()
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: missionsURL,
                includingPropertiesForKeys: [.creationDateKey, .fileSizeKey],
                options: .skipsHiddenFiles
            )
            
            let missionFiles = fileURLs.filter { $0.pathExtension == fileExtension }
            
            return missionFiles.compactMap { url in
                do {
                    let resourceValues = try url.resourceValues(forKeys: [.creationDateKey, .fileSizeKey])
                    return MissionFileInfo(
                        url: url,
                        name: url.deletingPathExtension().lastPathComponent,
                        createdDate: resourceValues.creationDate ?? Date(),
                        fileSize: resourceValues.fileSize ?? 0
                    )
                } catch {
                    Logger.shared.warning("Could not read file info for \(url.lastPathComponent)")
                    return nil
                }
            }.sorted { $0.createdDate > $1.createdDate }
            
        } catch {
            Logger.shared.error("Failed to list missions: \(error.localizedDescription)")
            return []
        }
    }
    
    /// Delete a mission file
    func deleteMission(at url: URL, completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try FileManager.default.removeItem(at: url)
            DispatchQueue.main.async {
                completion(.success(()))
            }
            Logger.shared.info("Mission deleted: \(url.lastPathComponent)")
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
            Logger.shared.error("Failed to delete mission: \(error.localizedDescription)")
        }
    }
    
    /// Export mission to share with other apps
    func exportMission(_ mission: JSONMission, from viewController: UIViewController) {
        let fileName = sanitizeFileName(mission.metadata.name) + "." + fileExtension
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            
            let jsonData = try encoder.encode(mission)
            try jsonData.write(to: tempURL)
            
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            activityVC.excludedActivityTypes = [.assignToContact, .saveToCameraRoll]
            
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = viewController.view
                popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                          y: viewController.view.bounds.midY,
                                          width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            viewController.present(activityVC, animated: true)
            
        } catch {
            Logger.shared.error("Failed to export mission: \(error.localizedDescription)")
            
            let alert = UIAlertController(title: "Export Failed", 
                                        message: error.localizedDescription, 
                                        preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            viewController.present(alert, animated: true)
        }
    }
    
    /// Import mission from Files app using document picker
    func importMission(from viewController: UIViewController, completion: @escaping (Result<JSONMission, Error>) -> Void) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        documentPicker.delegate = ImportDelegate(completion: completion)
        documentPicker.modalPresentationStyle = .formSheet
        
        viewController.present(documentPicker, animated: true)
    }
    
    // MARK: - Helper Methods
    
    private func getMissionsDirectory() -> URL {
        return documentsDirectory.appendingPathComponent(missionsSubdirectory)
    }
    
    private func sanitizeFileName(_ name: String) -> String {
        let invalidCharacters = CharacterSet(charactersIn: ":/\\?%*|\"<>")
        return name.components(separatedBy: invalidCharacters).joined(separator: "_")
    }
    
    /// Get the Files app path for easy user reference
    func getFilesAppPath() -> String {
        return "Files → On My iPad → DroneAuto → \(missionsSubdirectory)"
    }
}

// MARK: - Supporting Types

struct MissionFileInfo {
    let url: URL
    let name: String
    let createdDate: Date
    let fileSize: Int
    
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(fileSize))
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdDate)
    }
}

// MARK: - Document Picker Delegate

private class ImportDelegate: NSObject, UIDocumentPickerDelegate {
    let completion: (Result<JSONMission, Error>) -> Void
    
    init(completion: @escaping (Result<JSONMission, Error>) -> Void) {
        self.completion = completion
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            completion(.failure(MissionFileError.noFileSelected))
            return
        }
        
        MissionFileManager.shared.loadMission(from: url, completion: completion)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        completion(.failure(MissionFileError.importCancelled))
    }
}

// MARK: - Error Types

enum MissionFileError: LocalizedError {
    case noFileSelected
    case importCancelled
    case invalidFileFormat
    case fileNotFound
    
    var errorDescription: String? {
        switch self {
        case .noFileSelected:
            return "No file was selected"
        case .importCancelled:
            return "Import was cancelled"
        case .invalidFileFormat:
            return "Invalid mission file format"
        case .fileNotFound:
            return "Mission file not found"
        }
    }
}
