import UIKit
import CoreLocation

class MainViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let connectionStatusLabel = UILabel()
    private let missionStatusLabel = UILabel()
    
    private let batteryLevelLabel = UILabel()
    private let gpsSignalLabel = UILabel()
    private let altitudeLabel = UILabel()
    
    private let connectButton = UIButton(type: .system)
    private let uploadMissionButton = UIButton(type: .system)
    private let startMissionButton = UIButton(type: .system)
    private let pauseButton = UIButton(type: .system)
    private let stopButton = UIButton(type: .system)
    
    // File operation buttons
    private let saveMissionButton = UIButton(type: .system)
    private let loadMissionButton = UIButton(type: .system)
    private let exportMissionButton = UIButton(type: .system)
    private let createSampleButton = UIButton(type: .system)
    
    private let statusStackView = UIStackView()
    private let buttonsStackView = UIStackView()
    private let fileOperationsStackView = UIStackView()
    
    // MARK: - Properties
    private let droneService = DroneService.shared
    private var currentFlightPlan: FlightPlan?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupDroneService()
        createSampleFlightPlan()
        updateUI()
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Drone Auto Control"
        
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure labels
        titleLabel.text = "DJI Drone Automation"
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        connectionStatusLabel.text = "Connection: Disconnected"
        connectionStatusLabel.font = .systemFont(ofSize: 16)
        connectionStatusLabel.textColor = .systemRed
        connectionStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        missionStatusLabel.text = "Mission: Idle"
        missionStatusLabel.font = .systemFont(ofSize: 16)
        missionStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        batteryLevelLabel.text = "Battery: --"
        batteryLevelLabel.font = .systemFont(ofSize: 14)
        batteryLevelLabel.translatesAutoresizingMaskIntoConstraints = false
        
        gpsSignalLabel.text = "GPS: --"
        gpsSignalLabel.font = .systemFont(ofSize: 14)
        gpsSignalLabel.translatesAutoresizingMaskIntoConstraints = false
        
        altitudeLabel.text = "Altitude: --"
        altitudeLabel.font = .systemFont(ofSize: 14)
        altitudeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure buttons
        setupButton(connectButton, title: "Connect to Drone", action: #selector(connectButtonTapped))
        setupButton(uploadMissionButton, title: "Upload Mission", action: #selector(uploadMissionButtonTapped))
        setupButton(startMissionButton, title: "Start Mission", action: #selector(startMissionButtonTapped))
        setupButton(pauseButton, title: "Pause Mission", action: #selector(pauseButtonTapped))
        setupButton(stopButton, title: "Stop Mission", action: #selector(stopButtonTapped))
        
        // Configure file operation buttons
        setupButton(saveMissionButton, title: "Save to Files", action: #selector(saveMissionButtonTapped))
        setupButton(loadMissionButton, title: "Load from Files", action: #selector(loadMissionButtonTapped))
        setupButton(exportMissionButton, title: "Export Mission", action: #selector(exportMissionButtonTapped))
        setupButton(createSampleButton, title: "Create Sample", action: #selector(createSampleButtonTapped))
        
        // Configure stack views
        statusStackView.axis = .vertical
        statusStackView.spacing = 8
        statusStackView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = 12
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        fileOperationsStackView.axis = .vertical
        fileOperationsStackView.spacing = 12
        fileOperationsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add views to hierarchy
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        
        [connectionStatusLabel, missionStatusLabel, batteryLevelLabel, gpsSignalLabel, altitudeLabel].forEach {
            statusStackView.addArrangedSubview($0)
        }
        contentView.addSubview(statusStackView)
        
        [connectButton, uploadMissionButton, startMissionButton, pauseButton, stopButton].forEach {
            buttonsStackView.addArrangedSubview($0)
        }
        contentView.addSubview(buttonsStackView)
        
        [saveMissionButton, loadMissionButton, exportMissionButton, createSampleButton].forEach {
            fileOperationsStackView.addArrangedSubview($0)
        }
        contentView.addSubview(fileOperationsStackView)
    }
    
    private func setupButton(_ button: UIButton, title: String, action: Selector) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Scroll view
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Status stack
            statusStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            statusStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            statusStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Buttons stack
            buttonsStackView.topAnchor.constraint(equalTo: statusStackView.bottomAnchor, constant: 40),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // File operations stack
            fileOperationsStackView.topAnchor.constraint(equalTo: buttonsStackView.bottomAnchor, constant: 30),
            fileOperationsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            fileOperationsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            fileOperationsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Button heights
            connectButton.heightAnchor.constraint(equalToConstant: 50),
            uploadMissionButton.heightAnchor.constraint(equalToConstant: 50),
            startMissionButton.heightAnchor.constraint(equalToConstant: 50),
            pauseButton.heightAnchor.constraint(equalToConstant: 50),
            stopButton.heightAnchor.constraint(equalToConstant: 50),
            saveMissionButton.heightAnchor.constraint(equalToConstant: 50),
            loadMissionButton.heightAnchor.constraint(equalToConstant: 50),
            exportMissionButton.heightAnchor.constraint(equalToConstant: 50),
            createSampleButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupDroneService() {
        droneService.delegate = self
    }
    
    private func createSampleFlightPlan() {
        let waypoints = [
            Waypoint(latitude: 10.323520, longitude: -84.430511, altitude: 82.0),
            Waypoint(latitude: 10.323974, longitude: -84.430972, altitude: 82.0),
            Waypoint(latitude: 10.325653, longitude: -84.430167, altitude: 82.0),
        ]
        
        currentFlightPlan = FlightPlan(
            waypoints: waypoints,
            maxFlightSpeed: 15.0,
            autoFlightSpeed: 10.0,
            finishedAction: .goHome,
            headingMode: .auto
        )
    }
    
    // MARK: - Button Actions
    
    @objc private func connectButtonTapped() {
        // Connection is handled automatically by the SDK
        connectButton.isEnabled = false
        connectButton.setTitle("Connecting...", for: .normal)
    }
    
    @objc private func uploadMissionButtonTapped() {
        guard let flightPlan = currentFlightPlan else {
            showAlert(title: "Error", message: "No flight plan available")
            return
        }
        
        uploadMissionButton.isEnabled = false
        uploadMissionButton.setTitle("Uploading...", for: .normal)
        
        droneService.uploadMission(flightPlan) { [weak self] result in
            self?.uploadMissionButton.isEnabled = true
            self?.uploadMissionButton.setTitle("Upload Mission", for: .normal)
            
            switch result {
            case .success:
                self?.showAlert(title: "Success", message: "Mission uploaded successfully")
            case .failure(let error):
                self?.showAlert(title: "Upload Failed", message: error.localizedDescription)
            }
        }
    }
    
    @objc private func startMissionButtonTapped() {
        startMissionButton.isEnabled = false
        
        droneService.startMission { [weak self] result in
            self?.startMissionButton.isEnabled = true
            
            switch result {
            case .success:
                self?.showAlert(title: "Mission Started", message: "The drone is now executing the mission")
            case .failure(let error):
                self?.showAlert(title: "Start Failed", message: error.localizedDescription)
            }
        }
    }
    
    @objc private func pauseButtonTapped() {
        droneService.pauseMission { [weak self] result in
            switch result {
            case .success:
                self?.showAlert(title: "Mission Paused", message: "The mission has been paused")
            case .failure(let error):
                self?.showAlert(title: "Pause Failed", message: error.localizedDescription)
            }
        }
    }
    
    @objc private func stopButtonTapped() {
        droneService.stopMission { [weak self] result in
            switch result {
            case .success:
                self?.showAlert(title: "Mission Stopped", message: "The mission has been stopped")
            case .failure(let error):
                self?.showAlert(title: "Stop Failed", message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateUI() {
        // Initial UI state
        uploadMissionButton.isEnabled = false
        startMissionButton.isEnabled = false
        pauseButton.isEnabled = false
        stopButton.isEnabled = false
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - DroneStatusDelegate

extension MainViewController: DroneStatusDelegate {
    
    func droneConnectionStateDidChange(_ state: DroneConnectionState) {
        switch state {
        case .disconnected:
            connectionStatusLabel.text = "Connection: Disconnected"
            connectionStatusLabel.textColor = .systemRed
            connectButton.setTitle("Connect to Drone", for: .normal)
            connectButton.isEnabled = true
            uploadMissionButton.isEnabled = false
            
        case .connecting:
            connectionStatusLabel.text = "Connection: Connecting..."
            connectionStatusLabel.textColor = .systemOrange
            
        case .connected:
            connectionStatusLabel.text = "Connection: Connected"
            connectionStatusLabel.textColor = .systemGreen
            connectButton.setTitle("Connected", for: .normal)
            connectButton.isEnabled = false
            uploadMissionButton.isEnabled = true
            
        case .failed(let error):
            connectionStatusLabel.text = "Connection: Failed"
            connectionStatusLabel.textColor = .systemRed
            connectButton.setTitle("Retry Connection", for: .normal)
            connectButton.isEnabled = true
            showAlert(title: "Connection Failed", message: error.localizedDescription)
        }
    }
    
    func missionStateDidChange(_ state: MissionState) {
        switch state {
        case .idle:
            missionStatusLabel.text = "Mission: Idle"
            startMissionButton.isEnabled = false
            pauseButton.isEnabled = false
            stopButton.isEnabled = false
            
        case .preparing:
            missionStatusLabel.text = "Mission: Preparing..."
            
        case .ready:
            missionStatusLabel.text = "Mission: Ready"
            startMissionButton.isEnabled = true
            
        case .executing:
            missionStatusLabel.text = "Mission: Executing"
            startMissionButton.isEnabled = false
            pauseButton.isEnabled = true
            stopButton.isEnabled = true
            
        case .paused:
            missionStatusLabel.text = "Mission: Paused"
            startMissionButton.isEnabled = true // Resume
            pauseButton.isEnabled = false
            
        case .completed:
            missionStatusLabel.text = "Mission: Completed"
            startMissionButton.isEnabled = false
            pauseButton.isEnabled = false
            stopButton.isEnabled = false
            
        case .failed(let error):
            missionStatusLabel.text = "Mission: Failed"
            showAlert(title: "Mission Failed", message: error.localizedDescription)
        }
    }
    
    func droneStatusDidUpdate(_ status: DroneStatus) {
        batteryLevelLabel.text = "Battery: \(status.batteryLevel ?? 0)%"
        gpsSignalLabel.text = "GPS: Level \(status.gpsSignalLevel ?? 0)"
        altitudeLabel.text = "Altitude: \(String(format: "%.1f", status.altitude ?? 0))m"
        
        // Update battery color based on level
        if let batteryLevel = status.batteryLevel {
            switch batteryLevel {
            case 0...20:
                batteryLevelLabel.textColor = .systemRed
            case 21...50:
                batteryLevelLabel.textColor = .systemOrange
            default:
                batteryLevelLabel.textColor = .systemGreen
            }
        }
        
        // Update GPS color based on signal level
        if let gpsLevel = status.gpsSignalLevel {
            switch gpsLevel {
            case 0...2:
                gpsSignalLabel.textColor = .systemRed
            case 3...4:
                gpsSignalLabel.textColor = .systemOrange
            default:
                gpsSignalLabel.textColor = .systemGreen
            }
        }
    }
    
    // MARK: - File Operation Actions
    
    @objc private func saveMissionButtonTapped() {
        guard let flightPlan = currentFlightPlan else {
            showAlert(title: "No Mission", message: "Please create or load a mission first")
            return
        }
        
        let jsonMission = flightPlan.toJSONMission(
            name: "My Custom Mission \(Date().formatted(.dateTime.month().day().hour().minute()))",
            description: "Mission saved from DroneAuto app",
            tags: ["custom", "saved", "droneauto"]
        )
        
        MissionFileManager.shared.saveMission(jsonMission) { [weak self] result in
            switch result {
            case .success(let url):
                self?.showAlert(
                    title: "Mission Saved",
                    message: "Mission saved successfully!\n\nLocation: \(MissionFileManager.shared.getFilesAppPath())\n\nYou can access it in the Files app."
                )
            case .failure(let error):
                self?.showAlert(title: "Save Failed", message: error.localizedDescription)
            }
        }
    }
    
    @objc private func loadMissionButtonTapped() {
        MissionFileManager.shared.importMission(from: self) { [weak self] result in
            switch result {
            case .success(let jsonMission):
                // Use the enhanced JSON importer from PersonalMissionManager
                let importResult = PersonalMissionManager.shared.importJSONMission(from: try! JSONEncoder().encode(jsonMission))
                
                switch importResult {
                case .success(let flightPlan):
                    self?.currentFlightPlan = flightPlan
                    self?.showAlert(
                        title: "Mission Loaded Successfully",
                        message: """
                        Mission: '\(jsonMission.metadata.name)'
                        
                        • \(jsonMission.waypoints.count) waypoints loaded
                        • Author: \(jsonMission.metadata.author)
                        • Tags: \(jsonMission.metadata.tags.joined(separator: ", "))
                        
                        Mission has passed all safety validations.
                        """
                    )
                case .failure(let importError):
                    self?.showAlert(
                        title: "Mission Validation Failed",
                        message: importError.localizedDescription
                    )
                }
                
            case .failure(let error):
                if case MissionFileError.importCancelled = error {
                    // User cancelled, no need to show error
                    return
                }
                self?.showAlert(title: "Load Failed", message: error.localizedDescription)
            }
        }
    }
    
    @objc private func exportMissionButtonTapped() {
        guard let flightPlan = currentFlightPlan else {
            showAlert(title: "No Mission", message: "Please create or load a mission first")
            return
        }
        
        let jsonMission = flightPlan.toJSONMission(
            name: "Exported Mission \(Date().formatted(.dateTime.month().day()))",
            description: "Mission exported from DroneAuto app for sharing",
            tags: ["exported", "shared", "droneauto"]
        )
        
        MissionFileManager.shared.exportMission(jsonMission, from: self)
    }
    
    @objc private func createSampleButtonTapped() {
        let actionSheet = UIAlertController(title: "Create Sample Mission", 
                                          message: "Choose a mission template", 
                                          preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Basic Test Mission", style: .default) { [weak self] _ in
            let jsonMission = PersonalMissionManager.shared.createBasicTestJSONMission()
            self?.currentFlightPlan = jsonMission.toFlightPlan()
            self?.showAlert(title: "Sample Created", message: "Basic test mission with 4 waypoints created!")
        })
        
        actionSheet.addAction(UIAlertAction(title: "Grid Survey Mission", style: .default) { [weak self] _ in
            let jsonMission = PersonalMissionManager.shared.createGridSurveyJSONMission()
            self?.currentFlightPlan = jsonMission.toFlightPlan()
            self?.showAlert(title: "Sample Created", message: "Grid survey mission (3x3) created!")
        })
        
        actionSheet.addAction(UIAlertAction(title: "Perimeter Inspection", style: .default) { [weak self] _ in
            let corners = [
                CLLocationCoordinate2D(latitude: 10.323520, longitude: -84.430511),
                CLLocationCoordinate2D(latitude: 10.324520, longitude: -84.430511),
                CLLocationCoordinate2D(latitude: 10.324520, longitude: -84.431511),
                CLLocationCoordinate2D(latitude: 10.323520, longitude: -84.431511)
            ]
            let jsonMission = PersonalMissionManager.shared.createPerimeterJSONMission(corners: corners)
            self?.currentFlightPlan = jsonMission.toFlightPlan()
            self?.showAlert(title: "Sample Created", message: "Perimeter inspection mission created!")
        })
        
        actionSheet.addAction(UIAlertAction(title: "Test JSON Import", style: .default) { [weak self] _ in
            self?.testJSONImport()
        })
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popover = actionSheet.popoverPresentationController {
            popover.sourceView = createSampleButton
            popover.sourceRect = createSampleButton.bounds
        }
        
        present(actionSheet, animated: true)
    }
    
    // MARK: - Test Methods
    
    private func testJSONImport() {
        // Test with the sample JSON file
        let sampleJSONString = """
        {
          "metadata": {
            "author": "Jose",
            "createdDate": "2025-07-22T12:00:00Z",
            "description": "Test mission for JSON import validation",
            "modifiedDate": "2025-07-22T12:00:00Z",
            "name": "JSON Import Test",
            "tags": ["test", "import", "validation"],
            "version": "1.0"
          },
          "safetyLimits": {
            "geofenceCenter": {
              "latitude": 10.32352,
              "longitude": -84.430511
            },
            "geofenceRadius": 300.0,
            "maxAltitude": 100.0,
            "maxDistanceFromHome": 250.0,
            "minBatteryLevel": 25,
            "minGPSSignalLevel": 4
          },
          "settings": {
            "autoFlightSpeed": 6.0,
            "exitMissionOnRCSignalLost": true,
            "finishedAction": "goHome",
            "gotoFirstWaypointMode": "safely",
            "headingMode": "auto",
            "maxFlightSpeed": 12.0,
            "repeatTimes": 1
          },
          "waypoints": [
            {
              "actionRepeatTimes": 1,
              "actionTimeoutInSeconds": 60.0,
              "actions": [
                {
                  "parameters": null,
                  "type": "takePhoto"
                }
              ],
              "altitude": 75.0,
              "coordinate": {
                "latitude": 10.323520,
                "longitude": -84.430511
              },
              "cornerRadiusInMeters": 0.2,
              "gimbalPitch": -45.0,
              "heading": null,
              "speed": 6.0,
              "turnMode": "clockwise"
            },
            {
              "actionRepeatTimes": 1,
              "actionTimeoutInSeconds": 60.0,
              "actions": [
                {
                  "parameters": null,
                  "type": "takePhoto"
                }
              ],
              "altitude": 75.0,
              "coordinate": {
                "latitude": 10.324020,
                "longitude": -84.430511
              },
              "cornerRadiusInMeters": 0.2,
              "gimbalPitch": -45.0,
              "heading": null,
              "speed": 6.0,
              "turnMode": "clockwise"
            }
          ]
        }
        """
        
        // Test the JSON import system
        let importResult = PersonalMissionManager.shared.importJSONMission(from: sampleJSONString)
        
        switch importResult {
        case .success(let flightPlan):
            self.currentFlightPlan = flightPlan
            showAlert(
                title: "JSON Import Test Successful",
                message: """
                ✅ JSON parsing: Success
                ✅ Validation: Passed
                ✅ FlightPlan conversion: Success
                
                Mission loaded with \(flightPlan.waypoints.count) waypoints.
                All safety checks passed!
                """
            )
        case .failure(let error):
            showAlert(
                title: "JSON Import Test Failed",
                message: """
                ❌ Import failed with error:
                
                \(error.localizedDescription)
                
                Please check the JSON format and validation rules.
                """
            )
        }
    }
}
