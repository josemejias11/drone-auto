import Foundation
import DJISDK
import CoreLocation

class DroneService: NSObject {
    
    static let shared = DroneService()
    
    private var aircraft: DJIAircraft?
    private var missionOperator: DJIWaypointMissionOperator?
    
    weak var delegate: DroneStatusDelegate?
    
    private var connectionState: DroneConnectionState = .disconnected {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.droneConnectionStateDidChange(self.connectionState)
            }
        }
    }
    
    private var missionState: MissionState = .idle {
        didSet {
            DispatchQueue.main.async {
                self.delegate?.missionStateDidChange(self.missionState)
            }
        }
    }
    
    private override init() {
        super.init()
        setupProductConnectionObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Connection Management
    
    private func setupProductConnectionObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(productConnected),
            name: NSNotification.Name.DJIProductConnected,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(productDisconnected),
            name: NSNotification.Name.DJIProductDisconnected,
            object: nil
        )
    }
    
    @objc private func productConnected() {
        guard let aircraft = DJISDKManager.product() as? DJIAircraft else {
            connectionState = .failed(DroneError.unsupportedProduct)
            return
        }
        
        self.aircraft = aircraft
        self.missionOperator = aircraft.missionManager?.waypointMissionOperator()
        
        setupMissionOperatorCallbacks()
        startStatusUpdates()
        
        connectionState = .connected
    }
    
    @objc private func productDisconnected() {
        aircraft = nil
        missionOperator = nil
        connectionState = .disconnected
    }
    
    // MARK: - Mission Management
    
    private func setupMissionOperatorCallbacks() {
        guard let missionOperator = missionOperator else { return }
        
        missionOperator.addListener(toUploadEvent: self) { [weak self] event in
            DispatchQueue.main.async {
                switch event.currentState {
                case .uploading:
                    self?.missionState = .preparing
                case .readyToExecute:
                    self?.missionState = .ready
                default:
                    break
                }
                
                if let error = event.error {
                    self?.missionState = .failed(error)
                }
            }
        }
        
        missionOperator.addListener(toExecutionEvent: self) { [weak self] event in
            DispatchQueue.main.async {
                switch event.currentState {
                case .executing:
                    self?.missionState = .executing
                case .executionPaused:
                    self?.missionState = .paused
                default:
                    break
                }
                
                if event.currentState == .unknown && event.error == nil {
                    self?.missionState = .completed
                }
                
                if let error = event.error {
                    self?.missionState = .failed(error)
                }
            }
        }
    }
    
    func uploadMission(_ flightPlan: FlightPlan, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let missionOperator = missionOperator else {
            completion(.failure(DroneError.notConnected))
            return
        }
        
        // Use PersonalMissionManager to translate FlightPlan to DJI format
        let translationResult = PersonalMissionManager.shared.translateToDJIMission(flightPlan)
        
        switch translationResult {
        case .success(let djiMission):
            missionOperator.uploadMission(djiMission) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        Logger.shared.error("DJI mission upload failed: \(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        Logger.shared.info("DJI mission uploaded successfully")
                        completion(.success(()))
                    }
                }
            }
            
        case .failure(let translationError):
            Logger.shared.error("FlightPlan to DJI translation failed: \(translationError.localizedDescription)")
            completion(.failure(translationError))
        }
    }
    
    /// Upload mission from JSON format
    func uploadJSONMission(_ jsonMission: JSONMission, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let missionOperator = missionOperator else {
            completion(.failure(DroneError.notConnected))
            return
        }
        
        // Use PersonalMissionManager to translate JSON to DJI format
        let translationResult = PersonalMissionManager.shared.createEnhancedDJIMission(from: jsonMission)
        
        switch translationResult {
        case .success(let djiMission):
            missionOperator.uploadMission(djiMission) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        Logger.shared.error("Enhanced DJI mission upload failed: \(error.localizedDescription)")
                        completion(.failure(error))
                    } else {
                        Logger.shared.info("Enhanced DJI mission '\(jsonMission.metadata.name)' uploaded successfully")
                        completion(.success(()))
                    }
                }
            }
            
        case .failure(let translationError):
            Logger.shared.error("JSON to DJI translation failed: \(translationError.localizedDescription)")
            completion(.failure(translationError))
        }
    }
    
    func startMission(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let missionOperator = missionOperator else {
            completion(.failure(DroneError.notConnected))
            return
        }
        
        missionOperator.startMission { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func pauseMission(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let missionOperator = missionOperator else {
            completion(.failure(DroneError.notConnected))
            return
        }
        
        missionOperator.pauseMission { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func resumeMission(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let missionOperator = missionOperator else {
            completion(.failure(DroneError.notConnected))
            return
        }
        
        missionOperator.resumeMission { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
    
    func stopMission(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let missionOperator = missionOperator else {
            completion(.failure(DroneError.notConnected))
            return
        }
        
        missionOperator.stopMission { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    self.missionState = .idle
                    completion(.success(()))
                }
            }
        }
    }
    
    // MARK: - Status Updates

    private func startStatusUpdates() {
        // Start battery monitoring
        aircraft?.battery?.delegate = self

        // Start flight controller monitoring
        aircraft?.flightController?.delegate = self

        // Update drone status every 2 seconds
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateDroneStatus()
        }

        Logger.shared.info("Started drone status monitoring")
    }

    private func updateDroneStatus() {
        guard let aircraft = aircraft else { return }

        let flightController = aircraft.flightController
        let battery = aircraft.battery

        let status = DroneStatus(
            isConnected: true,
            batteryLevel: battery?.chargeRemainingInPercent,
            gpsSignalLevel: flightController?.gpsSignalLevel.rawValue,
            altitude: flightController?.state.altitude,
            speed: flightController?.state.velocityZ,
            isFlying: flightController?.state.isFlying ?? false,
            flightMode: flightController?.state.flightModeString
        )

        DispatchQueue.main.async {
            self.delegate?.droneStatusDidUpdate(status)
        }
    }
}

// MARK: - DroneError

enum DroneError: LocalizedError {
    case notConnected
    case unsupportedProduct
    case invalidFlightPlan
    case missionInProgress
    case insufficientBattery
    case poorGPSSignal
    
    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "Drone is not connected"
        case .unsupportedProduct:
            return "Connected product is not a supported aircraft"
        case .invalidFlightPlan:
            return "Flight plan is invalid"
        case .missionInProgress:
            return "Another mission is already in progress"
        case .insufficientBattery:
            return "Battery level is too low for flight"
        case .poorGPSSignal:
            return "GPS signal is too weak for autonomous flight"
        }
    }
}
