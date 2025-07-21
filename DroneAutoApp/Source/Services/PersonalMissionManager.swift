import Foundation
import CoreLocation

/// Personal Mission Manager for Jose's drone development and testing
class PersonalMissionManager {
    
    static let shared = PersonalMissionManager()
    
    // MARK: - Development Templates
    
    /// Pre-configured mission templates for common development scenarios
    enum MissionTemplate {
        case basicTest // Simple 3-point test flight
        case perimeter // Property boundary survey
        case gridSurvey // Systematic area coverage
        case photography // Photo capture points
        case custom(name: String) // User-defined template
    }
    
    // MARK: - Your Common Test Locations (Costa Rica)
    
    /// Safe testing locations - update with your actual spots
    private let testLocations: [String: CLLocationCoordinate2D] = [
        "Home Base": CLLocationCoordinate2D(latitude: 10.323520, longitude: -84.430511),
        "Test Field A": CLLocationCoordinate2D(latitude: 10.324000, longitude: -84.431000),
        "Test Field B": CLLocationCoordinate2D(latitude: 10.325000, longitude: -84.432000),
        "Open Area": CLLocationCoordinate2D(latitude: 10.326000, longitude: -84.433000)
    ]
    
    private init() {}
    
    // MARK: - Quick Mission Builders
    
    /// Creates a basic test mission for development
    func createBasicTestMission() -> FlightPlan {
        let baseLocation = testLocations["Home Base"]!
        
        let waypoints = [
            Waypoint(
                latitude: baseLocation.latitude,
                longitude: baseLocation.longitude,
                altitude: 50.0
            ),
            Waypoint(
                latitude: baseLocation.latitude + 0.001,
                longitude: baseLocation.longitude,
                altitude: 50.0
            ),
            Waypoint(
                latitude: baseLocation.latitude + 0.001,
                longitude: baseLocation.longitude + 0.001,
                altitude: 50.0
            ),
            Waypoint(
                latitude: baseLocation.latitude,
                longitude: baseLocation.longitude + 0.001,
                altitude: 50.0
            )
        ]
        
        return FlightPlan(
            waypoints: waypoints,
            maxFlightSpeed: HardwareConfiguration.developmentSettings.defaultFlightSpeed,
            autoFlightSpeed: HardwareConfiguration.developmentSettings.defaultFlightSpeed * 0.8,
            finishedAction: .goHome,
            headingMode: .auto
        )
    }
    
    /// Creates a grid survey mission for mapping/photography
    func createGridSurveyMission(
        center: CLLocationCoordinate2D,
        gridSize: Double = 0.002, // ~200m
        altitude: Float = 80.0,
        rows: Int = 3,
        columns: Int = 3
    ) -> FlightPlan {
        
        var waypoints: [Waypoint] = []
        let startLat = center.latitude - (gridSize / 2)
        let startLng = center.longitude - (gridSize / 2)
        let stepLat = gridSize / Double(rows - 1)
        let stepLng = gridSize / Double(columns - 1)
        
        for row in 0..<rows {
            let isEvenRow = row % 2 == 0
            let columnRange = isEvenRow ? (0..<columns) : (0..<columns).reversed()
            
            for col in columnRange {
                let lat = startLat + (Double(row) * stepLat)
                let lng = startLng + (Double(col) * stepLng)
                
                waypoints.append(Waypoint(
                    latitude: lat,
                    longitude: lng,
                    altitude: altitude,
                    gimbalPitch: -90.0 // Look straight down for mapping
                ))
            }
        }
        
        return FlightPlan(
            waypoints: waypoints,
            maxFlightSpeed: 12.0, // Slower for photography
            autoFlightSpeed: 8.0,
            finishedAction: .goHome,
            headingMode: .usingInitialDirection
        )
    }
    
    /// Creates a perimeter flight for property inspection
    func createPerimeterMission(
        corners: [CLLocationCoordinate2D],
        altitude: Float = 60.0
    ) -> FlightPlan {
        
        let waypoints = corners.map { coordinate in
            Waypoint(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                altitude: altitude,
                gimbalPitch: -45.0 // Angled down for inspection
            )
        }
        
        return FlightPlan(
            waypoints: waypoints,
            maxFlightSpeed: 10.0,
            autoFlightSpeed: 6.0,
            finishedAction: .goHome,
            headingMode: .usingWaypointHeading
        )
    }
    
    // MARK: - Development Helpers
    
    /// Validates mission for your specific hardware setup
    func validateForPersonalSetup(_ flightPlan: FlightPlan) -> ValidationResult {
        var warnings: [String] = []
        var errors: [String] = []
        
        // Check against Costa Rica regulations
        let maxAltitude = HardwareConfiguration.localConfiguration.maxLegalAltitude
        for (index, waypoint) in flightPlan.waypoints.enumerated() {
            if waypoint.altitude > Float(maxAltitude) {
                errors.append("Waypoint \(index + 1) altitude (\(waypoint.altitude)m) exceeds Costa Rica limit (\(maxAltitude)m)")
            }
        }
        
        // Check against Mavic 2 capabilities
        let maxRange = HardwareConfiguration.targetDrone.maxRange
        if flightPlan.totalDistance > Double(maxRange) {
            errors.append("Total mission distance (\(Int(flightPlan.totalDistance))m) exceeds Mavic 2 range (\(maxRange)m)")
        }
        
        // Check flight time against battery
        let maxFlightTime = HardwareConfiguration.targetDrone.maxFlightTime
        let estimatedTime = flightPlan.estimatedFlightTime / 60 // Convert to minutes
        if estimatedTime > Double(maxFlightTime) * 0.8 { // 80% safety margin
            warnings.append("Estimated flight time (\(Int(estimatedTime)) min) is close to Mavic 2 limit (\(maxFlightTime) min)")
        }
        
        // Development-specific checks
        if flightPlan.waypoints.count < 2 {
            errors.append("Mission needs at least 2 waypoints for testing")
        }
        
        return ValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings
        )
    }
    
    /// Saves mission to local files for reuse
    func saveMission(_ flightPlan: FlightPlan, name: String) {
        // Implementation for saving to iPad Files app
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let data = try encoder.encode(flightPlan)
            // Save to Documents directory for Files app access
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let filePath = documentsPath.appendingPathComponent("\(name).json")
            try data.write(to: filePath)
            
            Logger.shared.info("Mission '\(name)' saved successfully")
        } catch {
            Logger.shared.error("Failed to save mission '\(name)': \(error)")
        }
    }
    
    /// Loads previously saved mission
    func loadMission(name: String) -> FlightPlan? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentsPath.appendingPathComponent("\(name).json")
        
        do {
            let data = try Data(contentsOf: filePath)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let flightPlan = try decoder.decode(FlightPlan.self, from: data)
            
            Logger.shared.info("Mission '\(name)' loaded successfully")
            return flightPlan
        } catch {
            Logger.shared.error("Failed to load mission '\(name)': \(error)")
            return nil
        }
    }
    
    /// Lists all saved missions
    func listSavedMissions() -> [String] {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do {
            let files = try FileManager.default.contentsOfDirectory(at: documentsPath, includingPropertiesForKeys: nil)
            return files
                .filter { $0.pathExtension == "json" }
                .map { $0.deletingPathExtension().lastPathComponent }
        } catch {
            Logger.shared.error("Failed to list missions: \(error)")
            return []
        }
    }
}

// MARK: - Supporting Types

struct ValidationResult {
    let isValid: Bool
    let errors: [String]
    let warnings: [String]
    
    var summary: String {
        var result = isValid ? "✅ Mission Valid" : "❌ Mission Invalid"
        
        if !errors.isEmpty {
            result += "\n\nErrors:"
            errors.forEach { result += "\n• \($0)" }
        }
        
        if !warnings.isEmpty {
            result += "\n\nWarnings:"
            warnings.forEach { result += "\n• \($0)" }
        }
        
        return result
    }
}

// MARK: - FlightPlan Codable Extension

extension FlightPlan: Codable {
    private enum CodingKeys: String, CodingKey {
        case waypoints, maxFlightSpeed, autoFlightSpeed, finishedAction, headingMode
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(waypoints, forKey: .waypoints)
        try container.encode(maxFlightSpeed, forKey: .maxFlightSpeed)
        try container.encode(autoFlightSpeed, forKey: .autoFlightSpeed)
        try container.encode(finishedAction.rawValue, forKey: .finishedAction)
        try container.encode(headingMode.rawValue, forKey: .headingMode)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let waypoints = try container.decode([Waypoint].self, forKey: .waypoints)
        let maxFlightSpeed = try container.decode(Float.self, forKey: .maxFlightSpeed)
        let autoFlightSpeed = try container.decode(Float.self, forKey: .autoFlightSpeed)
        let finishedActionRaw = try container.decode(String.self, forKey: .finishedAction)
        let headingModeRaw = try container.decode(String.self, forKey: .headingMode)
        
        // Convert string back to enums (simplified for example)
        let finishedAction: FlightPlan.FinishedAction = finishedActionRaw == "goHome" ? .goHome : .noAction
        let headingMode: FlightPlan.HeadingMode = headingModeRaw == "auto" ? .auto : .usingInitialDirection
        
        self.init(
            waypoints: waypoints,
            maxFlightSpeed: maxFlightSpeed,
            autoFlightSpeed: autoFlightSpeed,
            finishedAction: finishedAction,
            headingMode: headingMode
        )
    }
}

extension Waypoint: Codable {
    private enum CodingKeys: String, CodingKey {
        case latitude, longitude, altitude, heading, gimbalPitch
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
        try container.encodeIfPresent(heading, forKey: .heading)
        try container.encodeIfPresent(gimbalPitch, forKey: .gimbalPitch)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        let altitude = try container.decode(Float.self, forKey: .altitude)
        let heading = try container.decodeIfPresent(Float.self, forKey: .heading)
        let gimbalPitch = try container.decodeIfPresent(Float.self, forKey: .gimbalPitch)
        
        self.init(
            latitude: latitude,
            longitude: longitude,
            altitude: altitude,
            heading: heading,
            gimbalPitch: gimbalPitch
        )
    }
}
