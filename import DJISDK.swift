// MARK: - Legacy Script (DEPRECATED)
// This file contains the original script for reference.
// For production use, please use the new DroneAutoApp structure.

import DJISDK
import CoreLocation

// NOTE: Fixed coordinate order - your original script had latitude/longitude swapped
// Costa Rica coordinates (corrected):
// Latitude should be around 10.x (not -84.x which would be Antarctica)
// Longitude should be around -84.x for Costa Rica

class LegacyDroneController {
    
    static func executeLegacyMission() {
        // Wait for drone connection
        guard let drone = DJISDKManager.product() as? DJIAircraft else {
            print("❌ Failed to connect to the drone.")
            return
        }
        
        print("✅ Drone connected successfully")
        
        // FIXED: Corrected coordinate order (latitude, longitude)
        let waypoints: [(latitude: Double, longitude: Double, altitude: Float)] = [
            (latitude: 10.323520, longitude: -84.430511, altitude: 82.0),
            (latitude: 10.323974, longitude: -84.430972, altitude: 82.0),
            (latitude: 10.325653, longitude: -84.430167, altitude: 82.0),
        ]
        
        // Validate coordinates before flight
        for (index, waypoint) in waypoints.enumerated() {
            let coordinate = CLLocationCoordinate2D(latitude: waypoint.latitude, longitude: waypoint.longitude)
            if !CLLocationCoordinate2DIsValid(coordinate) {
                print("❌ Invalid coordinate at waypoint \(index + 1)")
                return
            }
        }
        
        // Create Waypoint Mission
        let waypointMission = DJIMutableWaypointMission()
        waypointMission.maxFlightSpeed = 15.0
        waypointMission.autoFlightSpeed = 10.0
        waypointMission.finishedAction = .goHome  // Safety: Return home when done
        
        // Add waypoints to mission
        for (index, waypoint) in waypoints.enumerated() {
            let coordinate = CLLocationCoordinate2D(latitude: waypoint.latitude, longitude: waypoint.longitude)
            let djiWaypoint = DJIWaypoint(coordinate: coordinate)
            djiWaypoint.altitude = waypoint.altitude
            waypointMission.add(djiWaypoint)
            print("📍 Added waypoint \(index + 1): \(coordinate.latitude), \(coordinate.longitude)")
        }
        
        // Safety check: Verify mission is valid
        guard waypointMission.waypointCount > 1 else {
            print("❌ Mission must have at least 2 waypoints")
            return
        }
        
        // Get mission operator
        guard let missionOperator = drone.missionManager?.waypointMissionOperator() else {
            print("❌ Failed to get mission operator")
            return
        }
        
        // Upload mission
        print("📤 Uploading mission...")
        missionOperator.uploadMission(waypointMission) { error in
            if let error = error {
                print("❌ Error uploading mission: \(error.localizedDescription)")
            } else {
                print("✅ Mission uploaded successfully")
                
                // Start mission
                print("🚁 Starting mission...")
                missionOperator.startMission { error in
                    if let error = error {
                        print("❌ Error starting mission: \(error.localizedDescription)")
                    } else {
                        print("✅ Mission started successfully")
                        print("🎯 Drone is now executing autonomous flight")
                    }
                }
            }
        }
    }
}

// MARK: - Usage
// Uncomment the following line to execute the legacy mission
// LegacyDroneController.executeLegacyMission()
