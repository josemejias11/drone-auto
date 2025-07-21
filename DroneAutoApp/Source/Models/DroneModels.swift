import Foundation

enum DroneConnectionState {
    case disconnected
    case connecting
    case connected
    case failed(Error)
}

enum MissionState {
    case idle
    case preparing
    case ready
    case executing
    case paused
    case completed
    case failed(Error)
}

struct DroneStatus {
    let isConnected: Bool
    let batteryLevel: Int?
    let gpsSignalLevel: Int?
    let altitude: Float?
    let speed: Float?
    let isFlying: Bool
    let flightMode: String?
    
    var isReadyForFlight: Bool {
        return isConnected &&
               (batteryLevel ?? 0) > 20 && // Minimum 20% battery
               (gpsSignalLevel ?? 0) >= 3   // Minimum GPS signal level 3
    }
}

protocol DroneStatusDelegate: AnyObject {
    func droneConnectionStateDidChange(_ state: DroneConnectionState)
    func missionStateDidChange(_ state: MissionState)
    func droneStatusDidUpdate(_ status: DroneStatus)
}
