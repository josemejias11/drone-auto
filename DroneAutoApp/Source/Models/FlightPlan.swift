import Foundation
import CoreLocation

struct Waypoint {
    let coordinate: CLLocationCoordinate2D
    let altitude: Float
    let heading: Float?
    let gimbalPitch: Float?
    
    init(latitude: Double, longitude: Double, altitude: Float, heading: Float? = nil, gimbalPitch: Float? = nil) {
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.altitude = altitude
        self.heading = heading
        self.gimbalPitch = gimbalPitch
    }
    
    var isValid: Bool {
        return CLLocationCoordinate2DIsValid(coordinate) && 
               coordinate.latitude >= -90 && coordinate.latitude <= 90 &&
               coordinate.longitude >= -180 && coordinate.longitude <= 180 &&
               altitude >= 0 && altitude <= 500 // 500m max altitude for safety
    }
}

struct FlightPlan {
    let waypoints: [Waypoint]
    let maxFlightSpeed: Float
    let autoFlightSpeed: Float
    let finishedAction: FinishedAction
    let headingMode: HeadingMode
    
    enum FinishedAction {
        case noAction
        case goHome
        case autoLand
        case goFirstWaypoint
    }
    
    enum HeadingMode {
        case auto
        case usingInitialDirection
        case controlByRemoteController
        case usingWaypointHeading
    }
    
    init(waypoints: [Waypoint], 
         maxFlightSpeed: Float = 15.0, 
         autoFlightSpeed: Float = 10.0,
         finishedAction: FinishedAction = .goHome,
         headingMode: HeadingMode = .auto) {
        self.waypoints = waypoints
        self.maxFlightSpeed = maxFlightSpeed
        self.autoFlightSpeed = autoFlightSpeed
        self.finishedAction = finishedAction
        self.headingMode = headingMode
    }
    
    var isValid: Bool {
        return waypoints.count >= 2 && 
               waypoints.allSatisfy { $0.isValid } &&
               maxFlightSpeed > 0 && maxFlightSpeed <= 15 &&
               autoFlightSpeed > 0 && autoFlightSpeed <= maxFlightSpeed
    }
    
    var totalDistance: Double {
        guard waypoints.count > 1 else { return 0 }
        
        var totalDistance: Double = 0
        for i in 0..<(waypoints.count - 1) {
            let location1 = CLLocation(latitude: waypoints[i].coordinate.latitude, 
                                     longitude: waypoints[i].coordinate.longitude)
            let location2 = CLLocation(latitude: waypoints[i + 1].coordinate.latitude, 
                                     longitude: waypoints[i + 1].coordinate.longitude)
            totalDistance += location1.distance(from: location2)
        }
        return totalDistance
    }
    
    var estimatedFlightTime: TimeInterval {
        return totalDistance / Double(autoFlightSpeed)
    }
}
