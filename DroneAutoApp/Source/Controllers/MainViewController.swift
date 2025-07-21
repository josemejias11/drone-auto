import UIKit

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
    
    private let statusStackView = UIStackView()
    private let buttonsStackView = UIStackView()
    
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
        
        // Configure stack views
        statusStackView.axis = .vertical
        statusStackView.spacing = 8
        statusStackView.translatesAutoresizingMaskIntoConstraints = false
        
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = 12
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
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
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            // Button heights
            connectButton.heightAnchor.constraint(equalToConstant: 50),
            uploadMissionButton.heightAnchor.constraint(equalToConstant: 50),
            startMissionButton.heightAnchor.constraint(equalToConstant: 50),
            pauseButton.heightAnchor.constraint(equalToConstant: 50),
            stopButton.heightAnchor.constraint(equalToConstant: 50)
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
}
