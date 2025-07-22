import Foundation
import CoreLocation

// MARK: - JSON Mission Format Models

/// JSON-serializable mission format for Files app storage
struct JSONMission: Codable {
    let metadata: MissionMetadata
    let settings: MissionSettings
    let waypoints: [JSONWaypoint]
    let safetyLimits: SafetyLimits
    
    struct MissionMetadata: Codable {
        let name: String
        let description: String?
        let createdDate: Date
        let modifiedDate: Date
        let version: String
        let author: String
        let tags: [String]
        
        init(name: String, description: String? = nil, author: String = "Jose", tags: [String] = []) {
            self.name = name
            self.description = description
            self.createdDate = Date()
            self.modifiedDate = Date()
            self.version = "1.0"
            self.author = author
            self.tags = tags
        }
    }
    
    struct MissionSettings: Codable {
        let maxFlightSpeed: Float // m/s
        let autoFlightSpeed: Float // m/s
        let finishedAction: String // "goHome", "autoLand", "noAction", "goFirstWaypoint"
        let headingMode: String // "auto", "usingInitialDirection", "controlByRemoteController", "usingWaypointHeading"
        let gotoFirstWaypointMode: String // "safely", "pointToPoint"
        let exitMissionOnRCSignalLost: Bool
        let repeatTimes: Int
        
        init(maxFlightSpeed: Float = 15.0,
             autoFlightSpeed: Float = 10.0,
             finishedAction: String = "goHome",
             headingMode: String = "auto",
             gotoFirstWaypointMode: String = "safely",
             exitMissionOnRCSignalLost: Bool = true,
             repeatTimes: Int = 1) {
            self.maxFlightSpeed = maxFlightSpeed
            self.autoFlightSpeed = autoFlightSpeed
            self.finishedAction = finishedAction
            self.headingMode = headingMode
            self.gotoFirstWaypointMode = gotoFirstWaypointMode
            self.exitMissionOnRCSignalLost = exitMissionOnRCSignalLost
            self.repeatTimes = repeatTimes
        }
    }
    
    struct JSONWaypoint: Codable {
        let coordinate: Coordinate
        let altitude: Float // meters
        let heading: Float? // degrees (0-360)
        let cornerRadiusInMeters: Float
        let turnMode: String // "clockwise", "counterClockwise"
        let gimbalPitch: Float? // degrees (-90 to 30)
        let speed: Float? // m/s (optional override)
        let actionTimeoutInSeconds: Float
        let actionRepeatTimes: Int
        let actions: [WaypointAction]
        
        struct Coordinate: Codable {
            let latitude: Double
            let longitude: Double
            
            var clLocationCoordinate: CLLocationCoordinate2D {
                return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            }
            
            init(latitude: Double, longitude: Double) {
                self.latitude = latitude
                self.longitude = longitude
            }
            
            init(_ coordinate: CLLocationCoordinate2D) {
                self.latitude = coordinate.latitude
                self.longitude = coordinate.longitude
            }
        }
        
        struct WaypointAction: Codable {
            let type: String // "takePhoto", "startRecording", "stopRecording", "rotateGimbal", "rotateAircraft"
            let parameters: [String: String]? // Action-specific parameters
        }
        
        init(coordinate: CLLocationCoordinate2D,
             altitude: Float,
             heading: Float? = nil,
             cornerRadiusInMeters: Float = 0.2,
             turnMode: String = "clockwise",
             gimbalPitch: Float? = nil,
             speed: Float? = nil,
             actionTimeoutInSeconds: Float = 60.0,
             actionRepeatTimes: Int = 1,
             actions: [WaypointAction] = []) {
            self.coordinate = Coordinate(coordinate)
            self.altitude = altitude
            self.heading = heading
            self.cornerRadiusInMeters = cornerRadiusInMeters
            self.turnMode = turnMode
            self.gimbalPitch = gimbalPitch
            self.speed = speed
            self.actionTimeoutInSeconds = actionTimeoutInSeconds
            self.actionRepeatTimes = actionRepeatTimes
            self.actions = actions
        }
    }
    
    struct SafetyLimits: Codable {
        let maxAltitude: Float // meters
        let maxDistanceFromHome: Float // meters
        let minBatteryLevel: Int // percentage
        let minGPSSignalLevel: Int // 0-5
        let geofenceCenter: JSONWaypoint.Coordinate?
        let geofenceRadius: Float? // meters
        
        init(maxAltitude: Float = 120.0,
             maxDistanceFromHome: Float = 500.0,
             minBatteryLevel: Int = 20,
             minGPSSignalLevel: Int = 3,
             geofenceCenter: CLLocationCoordinate2D? = nil,
             geofenceRadius: Float? = nil) {
            self.maxAltitude = maxAltitude
            self.maxDistanceFromHome = maxDistanceFromHome
            self.minBatteryLevel = minBatteryLevel
            self.minGPSSignalLevel = minGPSSignalLevel
            self.geofenceCenter = geofenceCenter != nil ? JSONWaypoint.Coordinate(geofenceCenter!) : nil
            self.geofenceRadius = geofenceRadius
        }
    }
}

// MARK: - Conversion Extensions

extension JSONMission {
    /// Convert to internal FlightPlan model
    func toFlightPlan() -> FlightPlan {
        let waypoints = self.waypoints.map { jsonWaypoint in
            Waypoint(
                latitude: jsonWaypoint.coordinate.latitude,
                longitude: jsonWaypoint.coordinate.longitude,
                altitude: jsonWaypoint.altitude,
                heading: jsonWaypoint.heading,
                gimbalPitch: jsonWaypoint.gimbalPitch
            )
        }
        
        let finishedAction: FlightPlan.FinishedAction
        switch settings.finishedAction.lowercased() {
        case "gohome": finishedAction = .goHome
        case "autoland": finishedAction = .autoLand
        case "gofirstwaypoint": finishedAction = .goFirstWaypoint
        default: finishedAction = .noAction
        }
        
        let headingMode: FlightPlan.HeadingMode
        switch settings.headingMode.lowercased() {
        case "usinginitialDirection": headingMode = .usingInitialDirection
        case "controlbyremotecontroller": headingMode = .controlByRemoteController
        case "usingwaypointheading": headingMode = .usingWaypointHeading
        default: headingMode = .auto
        }
        
        return FlightPlan(
            waypoints: waypoints,
            maxFlightSpeed: settings.maxFlightSpeed,
            autoFlightSpeed: settings.autoFlightSpeed,
            finishedAction: finishedAction,
            headingMode: headingMode
        )
    }
}

extension FlightPlan {
    /// Convert from internal FlightPlan to JSON format
    func toJSONMission(name: String, description: String? = nil, tags: [String] = []) -> JSONMission {
        let jsonWaypoints = waypoints.map { waypoint in
            JSONMission.JSONWaypoint(
                coordinate: waypoint.coordinate,
                altitude: waypoint.altitude,
                heading: waypoint.heading,
                gimbalPitch: waypoint.gimbalPitch
            )
        }
        
        let finishedActionString: String
        switch finishedAction {
        case .goHome: finishedActionString = "goHome"
        case .autoLand: finishedActionString = "autoLand"
        case .goFirstWaypoint: finishedActionString = "goFirstWaypoint"
        case .noAction: finishedActionString = "noAction"
        }
        
        let headingModeString: String
        switch headingMode {
        case .auto: headingModeString = "auto"
        case .usingInitialDirection: headingModeString = "usingInitialDirection"
        case .controlByRemoteController: headingModeString = "controlByRemoteController"
        case .usingWaypointHeading: headingModeString = "usingWaypointHeading"
        }
        
        return JSONMission(
            metadata: JSONMission.MissionMetadata(name: name, description: description, tags: tags),
            settings: JSONMission.MissionSettings(
                maxFlightSpeed: maxFlightSpeed,
                autoFlightSpeed: autoFlightSpeed,
                finishedAction: finishedActionString,
                headingMode: headingModeString
            ),
            waypoints: jsonWaypoints,
            safetyLimits: JSONMission.SafetyLimits()
        )
    }
}
