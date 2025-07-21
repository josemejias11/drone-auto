import Foundation
import CoreLocation

struct LocationValidator {
    
    static func isValidCoordinate(_ coordinate: CLLocationCoordinate2D) -> Bool {
        return CLLocationCoordinate2DIsValid(coordinate) &&
               coordinate.latitude >= -90 && coordinate.latitude <= 90 &&
               coordinate.longitude >= -180 && coordinate.longitude <= 180
    }
    
    static func isWithinFlightBounds(_ coordinate: CLLocationCoordinate2D, center: CLLocationCoordinate2D, radiusKm: Double) -> Bool {
        let centerLocation = CLLocation(latitude: center.latitude, longitude: center.longitude)
        let targetLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let distance = centerLocation.distance(from: targetLocation)
        return distance <= (radiusKm * 1000) // Convert km to meters
    }
    
    static func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
    
    static func formatCoordinate(_ coordinate: CLLocationCoordinate2D) -> String {
        return String(format: "%.6f, %.6f", coordinate.latitude, coordinate.longitude)
    }
}

struct FlightSafetyChecker {
    
    static func validateFlightPlan(_ flightPlan: FlightPlan) -> [String] {
        var issues: [String] = []
        
        // Check minimum waypoints
        if flightPlan.waypoints.count < 2 {
            issues.append("Flight plan must have at least 2 waypoints")
        }
        
        // Check coordinate validity
        for (index, waypoint) in flightPlan.waypoints.enumerated() {
            if !LocationValidator.isValidCoordinate(waypoint.coordinate) {
                issues.append("Waypoint \(index + 1) has invalid coordinates")
            }
        }
        
        // Check altitude limits
        for (index, waypoint) in flightPlan.waypoints.enumerated() {
            if waypoint.altitude < 5 {
                issues.append("Waypoint \(index + 1) altitude too low (minimum 5m)")
            } else if waypoint.altitude > 500 {
                issues.append("Waypoint \(index + 1) altitude too high (maximum 500m)")
            }
        }
        
        // Check speed limits
        if flightPlan.maxFlightSpeed > 15 {
            issues.append("Maximum flight speed exceeds safety limit (15 m/s)")
        }
        
        if flightPlan.autoFlightSpeed > flightPlan.maxFlightSpeed {
            issues.append("Auto flight speed cannot exceed maximum flight speed")
        }
        
        // Check total distance
        if flightPlan.totalDistance > 10000 { // 10km
            issues.append("Total flight distance exceeds safety limit (10km)")
        }
        
        // Check estimated flight time
        if flightPlan.estimatedFlightTime > 1800 { // 30 minutes
            issues.append("Estimated flight time exceeds safety limit (30 minutes)")
        }
        
        return issues
    }
    
    static func checkBatteryLevel(_ batteryLevel: Int) -> [String] {
        var warnings: [String] = []
        
        if batteryLevel < 20 {
            warnings.append("Battery level critically low (\(batteryLevel)%)")
        } else if batteryLevel < 30 {
            warnings.append("Battery level low (\(batteryLevel)%)")
        }
        
        return warnings
    }
    
    static func checkGPSSignal(_ gpsLevel: Int) -> [String] {
        var warnings: [String] = []
        
        if gpsLevel < 3 {
            warnings.append("GPS signal too weak for autonomous flight (Level \(gpsLevel))")
        } else if gpsLevel < 4 {
            warnings.append("GPS signal marginal (Level \(gpsLevel))")
        }
        
        return warnings
    }
}
