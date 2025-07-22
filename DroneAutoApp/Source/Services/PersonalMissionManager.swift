import Foundation
import CoreLocation
import DJISDK

// MARK: - Mission Import/Export Error Types

enum MissionImportError: LocalizedError {
    case invalidJSONFormat(DecodingError?)
    case validationFailed(String)
    case fileReadError(Error)
    case unknownError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidJSONFormat(let decodingError):
            if let decodingError = decodingError {
                return "Invalid JSON format: \(decodingError.localizedDescription)"
            } else {
                return "Invalid JSON format"
            }
        case .validationFailed(let message):
            return "Mission validation failed: \(message)"
        case .fileReadError(let error):
            return "Could not read mission file: \(error.localizedDescription)"
        case .unknownError(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

enum MissionExportError: LocalizedError {
    case invalidFlightPlan(String)
    case encodingFailed(Error)
    case fileWriteError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidFlightPlan(let message):
            return "Invalid flight plan: \(message)"
        case .encodingFailed(let error):
            return "JSON encoding failed: \(error.localizedDescription)"
        case .fileWriteError(let error):
            return "Could not write mission file: \(error.localizedDescription)"
        }
    }
}

enum DJITranslationError: LocalizedError {
    case invalidFlightPlan(String)
    case invalidWaypoint(String)
    case invalidAction(String)
    case invalidDJIMission(String)
    case djiSDKError(Error)
    case unknownError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidFlightPlan(let message):
            return "Invalid flight plan: \(message)"
        case .invalidWaypoint(let message):
            return "Invalid waypoint: \(message)"
        case .invalidAction(let message):
            return "Invalid action: \(message)"
        case .invalidDJIMission(let message):
            return "Invalid DJI mission: \(message)"
        case .djiSDKError(let error):
            return "DJI SDK error: \(error.localizedDescription)"
        case .unknownError(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

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
    
    // MARK: - JSON Mission Import/Export
    
    /// Import and validate a JSON mission, converting to FlightPlan
    func importJSONMission(from data: Data) -> Result<FlightPlan, MissionImportError> {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let jsonMission = try decoder.decode(JSONMission.self, from: data)
            
            // Validate the mission
            if let validationError = validateJSONMission(jsonMission) {
                return .failure(validationError)
            }
            
            // Convert to FlightPlan with enhanced error handling
            let flightPlan = jsonMission.toFlightPlan()
            
            // Additional FlightPlan validation
            if let flightPlanError = validateFlightPlan(flightPlan) {
                return .failure(flightPlanError)
            }
            
            Logger.shared.info("Successfully imported JSON mission: \(jsonMission.metadata.name)")
            return .success(flightPlan)
            
        } catch let decodingError as DecodingError {
            Logger.shared.error("JSON decoding failed: \(decodingError.localizedDescription)")
            return .failure(.invalidJSONFormat(decodingError))
        } catch {
            Logger.shared.error("Mission import failed: \(error.localizedDescription)")
            return .failure(.unknownError(error))
        }
    }
    
    /// Import JSON mission from file URL
    func importJSONMission(from url: URL) -> Result<FlightPlan, MissionImportError> {
        do {
            let data = try Data(contentsOf: url)
            return importJSONMission(from: data)
        } catch {
            Logger.shared.error("Failed to read mission file: \(error.localizedDescription)")
            return .failure(.fileReadError(error))
        }
    }
    
    /// Import JSON mission from string
    func importJSONMission(from jsonString: String) -> Result<FlightPlan, MissionImportError> {
        guard let data = jsonString.data(using: .utf8) else {
            return .failure(.invalidJSONFormat(nil))
        }
        return importJSONMission(from: data)
    }
    
    /// Export FlightPlan to JSON format with enhanced metadata
    func exportToJSON(
        flightPlan: FlightPlan,
        name: String,
        description: String? = nil,
        tags: [String] = [],
        includeAdvancedSettings: Bool = true
    ) -> Result<JSONMission, MissionExportError> {
        
        // Validate FlightPlan before export
        if let validationError = validateFlightPlan(flightPlan) {
            return .failure(.invalidFlightPlan(validationError.localizedDescription))
        }
        
        // Create enhanced JSON mission
        var jsonMission = flightPlan.toJSONMission(name: name, description: description, tags: tags)
        
        // Add advanced settings if requested
        if includeAdvancedSettings {
            jsonMission = enhanceJSONMission(jsonMission, basedOn: flightPlan)
        }
        
        Logger.shared.info("Successfully exported mission to JSON: \(name)")
        return .success(jsonMission)
    }
    
    // MARK: - Validation Methods
    
    private func validateJSONMission(_ mission: JSONMission) -> MissionImportError? {
        // Check metadata
        if mission.metadata.name.isEmpty {
            return .validationFailed("Mission name cannot be empty")
        }
        
        // Check waypoints
        if mission.waypoints.isEmpty {
            return .validationFailed("Mission must have at least one waypoint")
        }
        
        if mission.waypoints.count > 99 {
            return .validationFailed("Mission cannot have more than 99 waypoints")
        }
        
        // Validate each waypoint
        for (index, waypoint) in mission.waypoints.enumerated() {
            if let waypointError = validateJSONWaypoint(waypoint, index: index) {
                return waypointError
            }
        }
        
        // Check settings
        if let settingsError = validateJSONSettings(mission.settings) {
            return settingsError
        }
        
        // Check safety limits
        if let safetyError = validateSafetyLimits(mission.safetyLimits) {
            return safetyError
        }
        
        return nil
    }
    
    private func validateJSONWaypoint(_ waypoint: JSONMission.JSONWaypoint, index: Int) -> MissionImportError? {
        let coord = waypoint.coordinate
        
        // Coordinate validation
        if !LocationValidator.isValidCoordinate(coord.clLocationCoordinate) {
            return .validationFailed("Waypoint \(index + 1): Invalid GPS coordinates")
        }
        
        // Altitude validation
        if waypoint.altitude < 0 || waypoint.altitude > 500 {
            return .validationFailed("Waypoint \(index + 1): Altitude must be between 0-500m")
        }
        
        // Gimbal pitch validation
        if let gimbalPitch = waypoint.gimbalPitch {
            if gimbalPitch < -90 || gimbalPitch > 30 {
                return .validationFailed("Waypoint \(index + 1): Gimbal pitch must be between -90° to 30°")
            }
        }
        
        // Heading validation
        if let heading = waypoint.heading {
            if heading < 0 || heading >= 360 {
                return .validationFailed("Waypoint \(index + 1): Heading must be between 0-359°")
            }
        }
        
        // Speed validation
        if let speed = waypoint.speed {
            if speed < 0.1 || speed > 20 {
                return .validationFailed("Waypoint \(index + 1): Speed must be between 0.1-20 m/s")
            }
        }
        
        // Actions validation
        for (actionIndex, action) in waypoint.actions.enumerated() {
            if let actionError = validateWaypointAction(action, waypoint: index + 1, action: actionIndex + 1) {
                return actionError
            }
        }
        
        return nil
    }
    
    private func validateJSONSettings(_ settings: JSONMission.MissionSettings) -> MissionImportError? {
        if settings.maxFlightSpeed < 1.0 || settings.maxFlightSpeed > 25.0 {
            return .validationFailed("Max flight speed must be between 1-25 m/s")
        }
        
        if settings.autoFlightSpeed < 0.5 || settings.autoFlightSpeed > settings.maxFlightSpeed {
            return .validationFailed("Auto flight speed must be between 0.5 m/s and max flight speed")
        }
        
        if settings.repeatTimes < 1 || settings.repeatTimes > 10 {
            return .validationFailed("Repeat times must be between 1-10")
        }
        
        return nil
    }
    
    private func validateSafetyLimits(_ limits: JSONMission.SafetyLimits) -> MissionImportError? {
        if limits.maxAltitude < 10 || limits.maxAltitude > 150 {
            return .validationFailed("Max altitude must be between 10-150m (Costa Rica regulations)")
        }
        
        if limits.maxDistanceFromHome < 50 || limits.maxDistanceFromHome > 2000 {
            return .validationFailed("Max distance from home must be between 50-2000m")
        }
        
        if limits.minBatteryLevel < 10 || limits.minBatteryLevel > 50 {
            return .validationFailed("Min battery level must be between 10-50%")
        }
        
        if limits.minGPSSignalLevel < 3 || limits.minGPSSignalLevel > 5 {
            return .validationFailed("Min GPS signal level must be between 3-5")
        }
        
        return nil
    }
    
    private func validateWaypointAction(_ action: JSONMission.JSONWaypoint.WaypointAction, waypoint: Int, action actionNum: Int) -> MissionImportError? {
        let validActionTypes = ["takePhoto", "startRecording", "stopRecording", "rotateGimbal", "rotateAircraft"]
        
        if !validActionTypes.contains(action.type) {
            return .validationFailed("Waypoint \(waypoint), Action \(actionNum): Invalid action type '\(action.type)'")
        }
        
        // Validate action-specific parameters
        switch action.type {
        case "rotateGimbal":
            if let params = action.parameters,
               let pitchStr = params["pitch"],
               let pitch = Float(pitchStr) {
                if pitch < -90 || pitch > 30 {
                    return .validationFailed("Waypoint \(waypoint), Action \(actionNum): Gimbal pitch must be -90° to 30°")
                }
            }
        case "rotateAircraft":
            if let params = action.parameters,
               let headingStr = params["heading"],
               let heading = Float(headingStr) {
                if heading < 0 || heading >= 360 {
                    return .validationFailed("Waypoint \(waypoint), Action \(actionNum): Aircraft heading must be 0-359°")
                }
            }
        default:
            break
        }
        
        return nil
    }
    
    private func validateFlightPlan(_ flightPlan: FlightPlan) -> MissionImportError? {
        // Validate waypoints
        for (index, waypoint) in flightPlan.waypoints.enumerated() {
            if !waypoint.isValid {
                return .validationFailed("FlightPlan waypoint \(index + 1) is invalid")
            }
        }
        
        // Check for reasonable distances between waypoints
        if flightPlan.waypoints.count > 1 {
            for i in 0..<(flightPlan.waypoints.count - 1) {
                let distance = LocationValidator.calculateDistance(
                    from: flightPlan.waypoints[i].coordinate,
                    to: flightPlan.waypoints[i + 1].coordinate
                )
                
                if distance > 1000 { // 1km max between waypoints
                    return .validationFailed("Distance between waypoints \(i + 1) and \(i + 2) is too large (>1km)")
                }
            }
        }
        
        return nil
    }
    
    private func enhanceJSONMission(_ mission: JSONMission, basedOn flightPlan: FlightPlan) -> JSONMission {
        // Add calculated metadata
        let totalDistance = calculateTotalMissionDistance(flightPlan)
        let estimatedFlightTime = calculateEstimatedFlightTime(flightPlan)
        
        var enhancedMission = mission
        
        // Update description with calculated info
        let enhancedDescription = """
        \(mission.metadata.description ?? "")
        
        Mission Statistics:
        • Total waypoints: \(flightPlan.waypoints.count)
        • Estimated distance: \(String(format: "%.0f", totalDistance))m
        • Estimated flight time: \(String(format: "%.1f", estimatedFlightTime)) minutes
        • Generated by DroneAuto v1.0
        """
        
        enhancedMission.metadata = JSONMission.MissionMetadata(
            name: mission.metadata.name,
            description: enhancedDescription,
            author: mission.metadata.author,
            tags: mission.metadata.tags + ["enhanced", "calculated"]
        )
        
        return enhancedMission
    }
    
    // MARK: - Helper Methods
    
    private func calculateTotalMissionDistance(_ flightPlan: FlightPlan) -> Double {
        guard flightPlan.waypoints.count > 1 else { return 0 }
        
        var totalDistance: Double = 0
        for i in 0..<(flightPlan.waypoints.count - 1) {
            totalDistance += LocationValidator.calculateDistance(
                from: flightPlan.waypoints[i].coordinate,
                to: flightPlan.waypoints[i + 1].coordinate
            )
        }
        return totalDistance
    }
    
    private func calculateEstimatedFlightTime(_ flightPlan: FlightPlan) -> Double {
        let totalDistance = calculateTotalMissionDistance(flightPlan)
        let avgSpeed = Double(flightPlan.autoFlightSpeed) // m/s
        
        // Add time for actions (estimate 10 seconds per waypoint for photos/actions)
        let actionTime = Double(flightPlan.waypoints.count * 10)
        
        let flightTime = totalDistance / avgSpeed + actionTime
        return flightTime / 60.0 // Convert to minutes
    }
    
    // MARK: - DJI Mission Translation
    
    /// Convert FlightPlan to DJIWaypointMission for execution
    func translateToDJIMission(_ flightPlan: FlightPlan) -> Result<DJIWaypointMission, DJITranslationError> {
        // Validate FlightPlan first
        if let validationError = validateFlightPlan(flightPlan) {
            return .failure(.invalidFlightPlan(validationError.localizedDescription))
        }
        
        // Create DJI Waypoint Mission
        let djiMission = DJIMutableWaypointMission()
        
        // Configure mission settings
        configureDJIMissionSettings(djiMission, from: flightPlan)
        
        // Convert waypoints
        do {
            let djiWaypoints = try convertWaypoints(flightPlan.waypoints)
            djiMission.add(djiWaypoints)
        } catch let error as DJITranslationError {
            return .failure(error)
        } catch {
            return .failure(.unknownError(error))
        }
        
        // Final validation
        if let validationError = validateDJIMission(djiMission) {
            return .failure(validationError)
        }
        
        Logger.shared.info("Successfully translated FlightPlan to DJI mission with \(djiMission.waypointCount) waypoints")
        return .success(djiMission)
    }
    
    /// Convert JSONMission directly to DJIWaypointMission
    func translateJSONToDJIMission(_ jsonMission: JSONMission) -> Result<DJIWaypointMission, DJITranslationError> {
        let flightPlan = jsonMission.toFlightPlan()
        return translateToDJIMission(flightPlan)
    }
    
    // MARK: - DJI Mission Configuration
    
    private func configureDJIMissionSettings(_ djiMission: DJIMutableWaypointMission, from flightPlan: FlightPlan) {
        // Flight speed settings
        djiMission.maxFlightSpeed = flightPlan.maxFlightSpeed
        djiMission.autoFlightSpeed = flightPlan.autoFlightSpeed
        
        // Finished action
        djiMission.finishedAction = convertFinishedAction(flightPlan.finishedAction)
        
        // Heading mode
        djiMission.headingMode = convertHeadingMode(flightPlan.headingMode)
        
        // Goto first waypoint mode (safely by default)
        djiMission.gotoFirstWaypointMode = .safely
        
        // Exit mission on RC signal lost (safety first)
        djiMission.exitMissionOnRCSignalLost = true
        
        // Mission execution times
        djiMission.repeatTimes = 1
        
        Logger.shared.info("Configured DJI mission settings: speed=\(flightPlan.autoFlightSpeed)m/s, action=\(flightPlan.finishedAction)")
    }
    
    private func convertWaypoints(_ waypoints: [Waypoint]) throws -> [DJIWaypoint] {
        var djiWaypoints: [DJIWaypoint] = []
        
        for (index, waypoint) in waypoints.enumerated() {
            let djiWaypoint = DJIWaypoint(coordinate: waypoint.coordinate)
            
            // Set altitude
            djiWaypoint.altitude = waypoint.altitude
            
            // Set heading if specified
            if let heading = waypoint.heading {
                djiWaypoint.heading = heading
            }
            
            // Configure waypoint behavior
            djiWaypoint.cornerRadiusInMeters = 0.2 // Smooth turns
            djiWaypoint.turnMode = .clockwise
            djiWaypoint.actionTimeoutInSeconds = 60
            djiWaypoint.actionRepeatTimes = 1
            
            // Add gimbal action if specified
            if let gimbalPitch = waypoint.gimbalPitch {
                let gimbalAction = DJIWaypointAction(actionType: .rotateGimbal, parameter: Int(gimbalPitch))
                djiWaypoint.add(gimbalAction)
                
                Logger.shared.debug("Added gimbal action to waypoint \(index + 1): \(gimbalPitch)°")
            }
            
            // Add photo capture action
            let photoAction = DJIWaypointAction(actionType: .shootPhoto, parameter: 0)
            djiWaypoint.add(photoAction)
            
            // Validate DJI waypoint
            if let error = validateDJIWaypoint(djiWaypoint, index: index) {
                throw error
            }
            
            djiWaypoints.append(djiWaypoint)
        }
        
        return djiWaypoints
    }
    
    private func convertFinishedAction(_ action: FlightPlan.FinishedAction) -> DJIWaypointMissionFinishedAction {
        switch action {
        case .noAction:
            return .noAction
        case .goHome:
            return .goHome
        case .autoLand:
            return .autoLand
        case .goFirstWaypoint:
            return .goToFirstWaypoint
        }
    }
    
    private func convertHeadingMode(_ mode: FlightPlan.HeadingMode) -> DJIWaypointMissionHeadingMode {
        switch mode {
        case .auto:
            return .auto
        case .usingInitialDirection:
            return .usingInitialDirection
        case .controlByRemoteController:
            return .controlByRemoteController
        case .usingWaypointHeading:
            return .usingWaypointHeading
        }
    }
    
    // MARK: - DJI Mission Validation
    
    private func validateDJIMission(_ mission: DJIMutableWaypointMission) -> DJITranslationError? {
        // Check waypoint count
        if mission.waypointCount == 0 {
            return .invalidDJIMission("Mission has no waypoints")
        }
        
        if mission.waypointCount > 99 {
            return .invalidDJIMission("DJI missions support maximum 99 waypoints")
        }
        
        // Check speed settings
        if mission.maxFlightSpeed < 1.0 || mission.maxFlightSpeed > 15.0 {
            return .invalidDJIMission("Max flight speed must be 1-15 m/s for DJI drones")
        }
        
        if mission.autoFlightSpeed < 0.5 || mission.autoFlightSpeed > mission.maxFlightSpeed {
            return .invalidDJIMission("Auto flight speed must be 0.5 m/s to max flight speed")
        }
        
        return nil
    }
    
    private func validateDJIWaypoint(_ waypoint: DJIWaypoint, index: Int) -> DJITranslationError? {
        // Coordinate validation
        if !CLLocationCoordinate2DIsValid(waypoint.coordinate) {
            return .invalidWaypoint("Waypoint \(index + 1): Invalid GPS coordinate")
        }
        
        // Altitude validation for DJI (more restrictive than our internal validation)
        if waypoint.altitude < 2.0 || waypoint.altitude > 120.0 {
            return .invalidWaypoint("Waypoint \(index + 1): DJI altitude must be 2-120m")
        }
        
        // Heading validation
        if waypoint.heading < 0 || waypoint.heading >= 360 {
            return .invalidWaypoint("Waypoint \(index + 1): Heading must be 0-359°")
        }
        
        return nil
    }
    
    // MARK: - Enhanced DJI Mission Creation
    
    /// Create an enhanced DJI mission from JSON with advanced actions
    func createEnhancedDJIMission(from jsonMission: JSONMission) -> Result<DJIWaypointMission, DJITranslationError> {
        let djiMission = DJIMutableWaypointMission()
        
        // Configure from JSON settings
        configureFromJSONSettings(djiMission, from: jsonMission)
        
        // Convert waypoints with enhanced actions
        do {
            let djiWaypoints = try convertEnhancedWaypoints(jsonMission.waypoints)
            djiMission.add(djiWaypoints)
        } catch let error as DJITranslationError {
            return .failure(error)
        } catch {
            return .failure(.unknownError(error))
        }
        
        // Final validation
        if let validationError = validateDJIMission(djiMission) {
            return .failure(validationError)
        }
        
        Logger.shared.info("Created enhanced DJI mission '\(jsonMission.metadata.name)' with \(djiMission.waypointCount) waypoints")
        return .success(djiMission)
    }
    
    private func configureFromJSONSettings(_ djiMission: DJIMutableWaypointMission, from jsonMission: JSONMission) {
        let settings = jsonMission.settings
        
        djiMission.maxFlightSpeed = settings.maxFlightSpeed
        djiMission.autoFlightSpeed = settings.autoFlightSpeed
        djiMission.exitMissionOnRCSignalLost = settings.exitMissionOnRCSignalLost
        djiMission.repeatTimes = UInt8(settings.repeatTimes)
        
        // Convert string-based settings
        djiMission.finishedAction = convertStringToFinishedAction(settings.finishedAction)
        djiMission.headingMode = convertStringToHeadingMode(settings.headingMode)
        djiMission.gotoFirstWaypointMode = convertStringToGotoMode(settings.gotoFirstWaypointMode)
    }
    
    private func convertEnhancedWaypoints(_ jsonWaypoints: [JSONMission.JSONWaypoint]) throws -> [DJIWaypoint] {
        var djiWaypoints: [DJIWaypoint] = []
        
        for (index, jsonWaypoint) in jsonWaypoints.enumerated() {
            let djiWaypoint = DJIWaypoint(coordinate: jsonWaypoint.coordinate.clLocationCoordinate)
            
            // Basic settings
            djiWaypoint.altitude = jsonWaypoint.altitude
            djiWaypoint.cornerRadiusInMeters = jsonWaypoint.cornerRadiusInMeters
            djiWaypoint.turnMode = jsonWaypoint.turnMode == "clockwise" ? .clockwise : .counterclockwise
            djiWaypoint.actionTimeoutInSeconds = jsonWaypoint.actionTimeoutInSeconds
            djiWaypoint.actionRepeatTimes = UInt8(jsonWaypoint.actionRepeatTimes)
            
            // Set heading if specified
            if let heading = jsonWaypoint.heading {
                djiWaypoint.heading = heading
            }
            
            // Convert JSON actions to DJI actions
            try addActionsToWaypoint(djiWaypoint, from: jsonWaypoint.actions, waypointIndex: index)
            
            // Validate DJI waypoint
            if let error = validateDJIWaypoint(djiWaypoint, index: index) {
                throw error
            }
            
            djiWaypoints.append(djiWaypoint)
        }
        
        return djiWaypoints
    }
    
    private func addActionsToWaypoint(_ djiWaypoint: DJIWaypoint, from actions: [JSONMission.JSONWaypoint.WaypointAction], waypointIndex: Int) throws {
        for (actionIndex, action) in actions.enumerated() {
            let djiAction: DJIWaypointAction
            
            switch action.type {
            case "takePhoto":
                djiAction = DJIWaypointAction(actionType: .shootPhoto, parameter: 0)
                
            case "startRecording":
                djiAction = DJIWaypointAction(actionType: .startRecord, parameter: 0)
                
            case "stopRecording":
                djiAction = DJIWaypointAction(actionType: .stopRecord, parameter: 0)
                
            case "rotateGimbal":
                guard let params = action.parameters,
                      let pitchStr = params["pitch"],
                      let pitch = Float(pitchStr) else {
                    throw DJITranslationError.invalidAction("Waypoint \(waypointIndex + 1), Action \(actionIndex + 1): rotateGimbal requires 'pitch' parameter")
                }
                djiAction = DJIWaypointAction(actionType: .rotateGimbal, parameter: Int(pitch))
                
            case "rotateAircraft":
                guard let params = action.parameters,
                      let headingStr = params["heading"],
                      let heading = Float(headingStr) else {
                    throw DJITranslationError.invalidAction("Waypoint \(waypointIndex + 1), Action \(actionIndex + 1): rotateAircraft requires 'heading' parameter")
                }
                djiAction = DJIWaypointAction(actionType: .rotateAircraft, parameter: Int(heading))
                
            default:
                throw DJITranslationError.invalidAction("Waypoint \(waypointIndex + 1), Action \(actionIndex + 1): Unknown action type '\(action.type)'")
            }
            
            djiWaypoint.add(djiAction)
            Logger.shared.debug("Added \(action.type) action to waypoint \(waypointIndex + 1)")
        }
    }
    
    private func convertStringToFinishedAction(_ action: String) -> DJIWaypointMissionFinishedAction {
        switch action.lowercased() {
        case "gohome": return .goHome
        case "autoland": return .autoLand
        case "gofirstwaypoint": return .goToFirstWaypoint
        default: return .noAction
        }
    }
    
    private func convertStringToHeadingMode(_ mode: String) -> DJIWaypointMissionHeadingMode {
        switch mode.lowercased() {
        case "usinginitialDirection": return .usingInitialDirection
        case "controlbyremotecontroller": return .controlByRemoteController
        case "usingwaypointheading": return .usingWaypointHeading
        default: return .auto
        }
    }
    
    private func convertStringToGotoMode(_ mode: String) -> DJIWaypointMissionGotoWaypointMode {
        switch mode.lowercased() {
        case "pointtopoint": return .pointToPoint
        default: return .safely
        }
    }
    
    // MARK: - JSON Mission Builders
    
    /// Creates a JSON mission for the basic test flight
    func createBasicTestJSONMission() -> JSONMission {
        let baseLocation = testLocations["Home Base"]!
        
        let waypoints = [
            JSONMission.JSONWaypoint(
                coordinate: baseLocation,
                altitude: 50.0,
                gimbalPitch: -45.0,
                actions: [
                    JSONMission.JSONWaypoint.WaypointAction(
                        type: "takePhoto",
                        parameters: nil
                    )
                ]
            ),
            JSONMission.JSONWaypoint(
                coordinate: CLLocationCoordinate2D(
                    latitude: baseLocation.latitude + 0.001,
                    longitude: baseLocation.longitude
                ),
                altitude: 50.0,
                gimbalPitch: -45.0,
                actions: [
                    JSONMission.JSONWaypoint.WaypointAction(
                        type: "takePhoto",
                        parameters: nil
                    )
                ]
            ),
            JSONMission.JSONWaypoint(
                coordinate: CLLocationCoordinate2D(
                    latitude: baseLocation.latitude + 0.001,
                    longitude: baseLocation.longitude + 0.001
                ),
                altitude: 50.0,
                gimbalPitch: -45.0,
                actions: [
                    JSONMission.JSONWaypoint.WaypointAction(
                        type: "takePhoto",
                        parameters: nil
                    )
                ]
            ),
            JSONMission.JSONWaypoint(
                coordinate: CLLocationCoordinate2D(
                    latitude: baseLocation.latitude,
                    longitude: baseLocation.longitude + 0.001
                ),
                altitude: 50.0,
                gimbalPitch: -45.0,
                actions: [
                    JSONMission.JSONWaypoint.WaypointAction(
                        type: "takePhoto",
                        parameters: nil
                    )
                ]
            )
        ]
        
        return JSONMission(
            metadata: JSONMission.MissionMetadata(
                name: "Basic Test Mission",
                description: "4-waypoint square pattern for system validation and testing",
                tags: ["test", "development", "basic", "validation"]
            ),
            settings: JSONMission.MissionSettings(
                maxFlightSpeed: 10.0,
                autoFlightSpeed: 5.0,
                finishedAction: "goHome",
                headingMode: "auto",
                exitMissionOnRCSignalLost: true
            ),
            waypoints: waypoints,
            safetyLimits: JSONMission.SafetyLimits(
                maxAltitude: 120.0,
                maxDistanceFromHome: 200.0,
                geofenceCenter: baseLocation,
                geofenceRadius: 300.0
            )
        )
    }
    
    /// Creates a JSON mission for grid survey pattern
    func createGridSurveyJSONMission(
        center: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 10.323520, longitude: -84.430511),
        gridSize: Double = 0.002,
        altitude: Float = 80.0,
        rows: Int = 3,
        columns: Int = 3
    ) -> JSONMission {
        
        var waypoints: [JSONMission.JSONWaypoint] = []
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
                
                let isCorner = (row == 0 || row == rows - 1) && 
                              (col == 0 || col == columns - 1)
                
                var actions: [JSONMission.JSONWaypoint.WaypointAction] = [
                    JSONMission.JSONWaypoint.WaypointAction(
                        type: "takePhoto",
                        parameters: nil
                    )
                ]
                
                // Add video recording at corners
                if isCorner {
                    actions.append(
                        JSONMission.JSONWaypoint.WaypointAction(
                            type: "startRecording",
                            parameters: ["duration": "5"]
                        )
                    )
                }
                
                waypoints.append(JSONMission.JSONWaypoint(
                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng),
                    altitude: altitude,
                    gimbalPitch: -90.0,
                    speed: 8.0, // Slower speed for mapping
                    actions: actions
                ))
            }
        }
        
        return JSONMission(
            metadata: JSONMission.MissionMetadata(
                name: "Grid Survey Mission",
                description: "Systematic \(rows)x\(columns) grid pattern for area mapping and photography",
                tags: ["survey", "mapping", "grid", "photography", "systematic"]
            ),
            settings: JSONMission.MissionSettings(
                maxFlightSpeed: 12.0,
                autoFlightSpeed: 8.0,
                finishedAction: "goHome",
                headingMode: "auto",
                exitMissionOnRCSignalLost: true
            ),
            waypoints: waypoints,
            safetyLimits: JSONMission.SafetyLimits(
                maxAltitude: 120.0,
                maxDistanceFromHome: 500.0,
                geofenceCenter: center,
                geofenceRadius: 600.0
            )
        )
    }
    
    /// Creates a JSON mission for perimeter inspection
    func createPerimeterJSONMission(corners: [CLLocationCoordinate2D], altitude: Float = 60.0) -> JSONMission {
        let waypoints = corners.enumerated().map { (index, coordinate) in
            JSONMission.JSONWaypoint(
                coordinate: coordinate,
                altitude: altitude,
                heading: nil, // Will use waypoint heading mode
                gimbalPitch: -45.0, // Angled view for inspection
                speed: 6.0, // Slower speed for inspection
                actions: [
                    JSONMission.JSONWaypoint.WaypointAction(
                        type: "takePhoto",
                        parameters: nil
                    ),
                    JSONMission.JSONWaypoint.WaypointAction(
                        type: "startRecording",
                        parameters: ["duration": "10"]
                    )
                ]
            )
        }
        
        // Calculate center point for geofence
        let centerLat = corners.map { $0.latitude }.reduce(0, +) / Double(corners.count)
        let centerLng = corners.map { $0.longitude }.reduce(0, +) / Double(corners.count)
        let center = CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng)
        
        // Calculate geofence radius (distance to furthest corner + buffer)
        let maxDistance = corners.map { corner in
            let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
            let cornerLocation = CLLocation(latitude: corner.latitude, longitude: corner.longitude)
            return centerLocation.distance(from: cornerLocation)
        }.max() ?? 1000.0
        
        return JSONMission(
            metadata: JSONMission.MissionMetadata(
                name: "Perimeter Inspection",
                description: "Property boundary inspection with \(corners.count) waypoints",
                tags: ["inspection", "perimeter", "boundary", "security", "patrol"]
            ),
            settings: JSONMission.MissionSettings(
                maxFlightSpeed: 10.0,
                autoFlightSpeed: 6.0,
                finishedAction: "goHome",
                headingMode: "usingWaypointHeading",
                exitMissionOnRCSignalLost: true
            ),
            waypoints: waypoints,
            safetyLimits: JSONMission.SafetyLimits(
                maxAltitude: 120.0,
                maxDistanceFromHome: Float(maxDistance + 100.0),
                geofenceCenter: center,
                geofenceRadius: Float(maxDistance + 150.0)
            )
        )
    }
    
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
