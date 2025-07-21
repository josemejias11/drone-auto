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
        
        guard flightPlan.isValid else {
            completion(.failure(DroneError.invalidFlightPlan))
            return
        }
        
        let mission = createDJIMission(from: flightPlan)
        
        missionOperator.uploadMission(mission) { error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
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
        // Update drone status every 2 seconds
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateDroneStatus()
        }
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
    
    // MARK: - Helper Methods
    
    private func createDJIMission(from flightPlan: FlightPlan) -> DJIMutableWaypointMission {
        let mission = DJIMutableWaypointMission()
        
        mission.maxFlightSpeed = flightPlan.maxFlightSpeed
        mission.autoFlightSpeed = flightPlan.autoFlightSpeed
        
        // Convert custom enums to DJI enums
        switch flightPlan.finishedAction {
        case .noAction:
            mission.finishedAction = .noAction
        case .goHome:
            mission.finishedAction = .goHome
        case .autoLand:
            mission.finishedAction = .autoLand
        case .goFirstWaypoint:
            mission.finishedAction = .goFirstWaypoint
        }
        
        switch flightPlan.headingMode {
        case .auto:
            mission.headingMode = .auto
        case .usingInitialDirection:
            mission.headingMode = .usingInitialDirection
        case .controlByRemoteController:
            mission.headingMode = .controlByRemoteController
        case .usingWaypointHeading:
            mission.headingMode = .usingWaypointHeading
        }
        
        // Add waypoints
        for waypoint in flightPlan.waypoints {
            let djiWaypoint = DJIWaypoint(coordinate: waypoint.coordinate)
            djiWaypoint.altitude = waypoint.altitude
            
            if let heading = waypoint.heading {
                djiWaypoint.heading = heading
            }
            
            if let gimbalPitch = waypoint.gimbalPitch {
                let gimbalAction = DJIWaypointAction(actionType: .gimbalPitch, param: gimbalPitch)
                djiWaypoint.add(gimbalAction)
            }
            
            mission.add(djiWaypoint)
        }
        
        return mission
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
