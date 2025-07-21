import Foundation

/// Hardware-specific configuration for Jose's personal drone development setup
struct HardwareConfiguration {
    
    // MARK: - Development Device Configuration
    
    /// iPad Pro 11" M2 specifications
    static let developmentDevice = DeviceSpec(
        name: "iPad Pro 11\" M2",
        chipset: "Apple M2",
        ram: "8GB/16GB",
        screenSize: "11 inches",
        maxBrightness: 600, // nits - important for outdoor use
        supportsProMotion: true,
        supportsThunderbolt: true
    )
    
    // MARK: - Drone Configuration
    
    /// DJI Mavic 2 Pro/Zoom specifications and capabilities
    static let targetDrone = DroneSpec(
        model: "DJI Mavic 2 Classic",
        maxFlightTime: 31, // minutes
        maxRange: 8000, // meters (FCC)
        maxAltitude: 6000, // meters above sea level
        maxSpeed: 72, // km/h in Sport mode
        camera: CameraSpec(
            sensor: "1\" CMOS", // Mavic 2 Pro
            maxResolution: "20MP",
            videoResolution: "4K/30fps",
            hasGimbal: true,
            gimbalRange: (-90, 30) // degrees (down, up)
        ),
        sensors: SensorCapabilities(
            hasObstacleAvoidance: true,
            hasDownwardVision: true,
            hasIMU: true,
            hasCompass: true,
            hasGPS: true,
            hasGLONASS: true
        ),
        flightModes: [
            "Position", "Sport", "Cinematic", 
            "Tripod", "ActiveTrack", "Point of Interest"
        ]
    )
    
    // MARK: - Personal Development Settings
    
    /// Optimized settings for your development workflow
    static let developmentSettings = DevelopmentConfig(
        defaultTestAltitude: 50.0, // meters - safe testing height
        maxTestRange: 1000.0, // meters - stay within visual range
        defaultFlightSpeed: 8.0, // m/s - balance between safety and efficiency  
        batteryWarningLevel: 30, // percent - conservative for testing
        gpsMinimumLevel: 4, // strong signal required for autonomous flight
        enableDetailedLogging: true,
        autoSaveFlightLogs: true,
        testModeEnabled: true
    )
    
    // MARK: - iPad Pro Optimizations
    
    /// Settings optimized for iPad Pro development
    static let ipadOptimizations = iPadConfig(
        useExternalKeyboard: true, // assume Magic Keyboard or similar
        enableSplitView: true, // for monitoring while coding
        preferLandscapeForFlightControl: true,
        enableApplePencilSupport: true, // for flight path drawing
        optimizeForM2Chip: true,
        enableMetalAcceleration: true // for real-time map rendering
    )
    
    // MARK: - Costa Rica Specific Settings
    
    /// Local regulations and environmental considerations
    static let localConfiguration = LocalConfig(
        country: "Costa Rica",
        maxLegalAltitude: 122.0, // meters (400 feet)
        requiresRegistration: false, // for recreational use under 25kg
        defaultCoordinateSystem: .wgs84,
        timezone: "America/Costa_Rica",
        typicalWindConditions: "Light to moderate trade winds",
        rainySeasonMonths: [5, 6, 7, 8, 9, 10], // May to October
        recommendedFlightHours: "Early morning (6-10 AM) or late afternoon (4-6 PM)"
    )
}

// MARK: - Supporting Structures

struct DeviceSpec {
    let name: String
    let chipset: String
    let ram: String
    let screenSize: String
    let maxBrightness: Int
    let supportsProMotion: Bool
    let supportsThunderbolt: Bool
}

struct DroneSpec {
    let model: String
    let maxFlightTime: Int
    let maxRange: Int
    let maxAltitude: Int
    let maxSpeed: Int
    let camera: CameraSpec
    let sensors: SensorCapabilities
    let flightModes: [String]
}

struct CameraSpec {
    let sensor: String
    let maxResolution: String
    let videoResolution: String
    let hasGimbal: Bool
    let gimbalRange: (down: Int, up: Int)
}

struct SensorCapabilities {
    let hasObstacleAvoidance: Bool
    let hasDownwardVision: Bool
    let hasIMU: Bool
    let hasCompass: Bool
    let hasGPS: Bool
    let hasGLONASS: Bool
}

struct DevelopmentConfig {
    let defaultTestAltitude: Double
    let maxTestRange: Double
    let defaultFlightSpeed: Double
    let batteryWarningLevel: Int
    let gpsMinimumLevel: Int
    let enableDetailedLogging: Bool
    let autoSaveFlightLogs: Bool
    let testModeEnabled: Bool
}

struct iPadConfig {
    let useExternalKeyboard: Bool
    let enableSplitView: Bool
    let preferLandscapeForFlightControl: Bool
    let enableApplePencilSupport: Bool
    let optimizeForM2Chip: Bool
    let enableMetalAcceleration: Bool
}

struct LocalConfig {
    let country: String
    let maxLegalAltitude: Double
    let requiresRegistration: Bool
    let defaultCoordinateSystem: CoordinateSystem
    let timezone: String
    let typicalWindConditions: String
    let rainySeasonMonths: [Int]
    let recommendedFlightHours: String
}

enum CoordinateSystem {
    case wgs84
    case utm
}
