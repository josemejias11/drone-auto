# DJI Drone Automation App

A comprehensive iOS application for automating DJI drone flights using waypoint missions.

## Features

- ✈️ **Autonomous Flight Control**: Create and execute waypoint missions
- 📡 **Real-time Monitoring**: Live status updates for battery, GPS, altitude
- 🛡️ **Safety Checks**: Comprehensive pre-flight validation
- 🎯 **Mission Management**: Upload, start, pause, resume, and stop missions
- 📱 **Modern UI**: Clean, intuitive interface for mission control

## Project Structure

```
DroneAutoApp/
├── Source/
│   ├── AppDelegate.swift          # App initialization and DJI SDK setup
│   ├── SceneDelegate.swift        # Scene management (iOS 13+)
│   ├── Controllers/
│   │   └── MainViewController.swift    # Main UI controller
│   ├── Models/
│   │   ├── FlightPlan.swift           # Flight plan and waypoint models
│   │   └── DroneModels.swift          # Drone status and state models
│   ├── Services/
│   │   └── DroneService.swift         # Core drone communication service
│   ├── Views/
│   │   └── (Custom UI components)
│   └── Utils/
│       ├── Logger.swift               # Logging utility
│       └── SafetyUtils.swift          # Safety validation utilities
├── Resources/
│   └── Assets/                        # App icons, images, etc.
├── Configuration/
│   └── Info.plist                     # App configuration
└── Package.swift                      # Swift Package Manager manifest
```

## Requirements

- iOS 13.0+
- Xcode 12.0+
- DJI Mobile SDK 4.16+
- Valid DJI Developer Account

## Setup Instructions

### 1. DJI SDK Installation

The DJI Mobile SDK is not available via Swift Package Manager. You need to:

1. Register as a DJI Developer at [developer.dji.com](https://developer.dji.com)
2. Create a new app and get your App Key
3. Download the DJI Mobile SDK from the developer portal
4. Add the framework to your Xcode project

### 2. Xcode Project Setup

1. Create a new iOS project in Xcode
2. Copy all files from the `DroneAutoApp/Source` directory to your project
3. Add the DJI SDK frameworks to your project
4. Update your App Key in `AppDelegate.swift`
5. Configure signing and capabilities

### 3. Required Capabilities

Add these to your project's capabilities:
- Location Services
- Camera Access
- Background Modes (if needed)

### 4. Update App Key

Replace `YOUR_APP_KEY_HERE` in `AppDelegate.swift` with your actual DJI App Key:

```swift
DJISDKManager.registerApp(withAppKey: "YOUR_ACTUAL_APP_KEY")
```

## Usage

### Basic Flight Plan

The app includes a sample flight plan with three waypoints:

```swift
let waypoints = [
    Waypoint(latitude: 10.323520, longitude: -84.430511, altitude: 82.0),
    Waypoint(latitude: 10.323974, longitude: -84.430972, altitude: 82.0),
    Waypoint(latitude: 10.325653, longitude: -84.430167, altitude: 82.0),
]
```

### Safety Features

- **Battery Level Monitoring**: Prevents flight with low battery
- **GPS Signal Validation**: Ensures adequate GPS signal strength
- **Coordinate Validation**: Verifies waypoints are within valid ranges
- **Flight Boundary Checking**: Configurable flight area restrictions
- **Altitude Limits**: Enforces minimum and maximum altitude constraints

### Mission Control

1. **Connect**: Establish connection with the drone
2. **Upload**: Upload the flight plan to the drone
3. **Start**: Begin mission execution
4. **Monitor**: Real-time status updates during flight
5. **Control**: Pause, resume, or stop missions as needed

## Code Architecture

### Services Layer
- **DroneService**: Centralized drone communication and mission management
- Singleton pattern for global access
- Delegate pattern for status updates

### Models Layer
- **FlightPlan**: Encapsulates waypoints and flight parameters
- **DroneModels**: Status and state management
- **Waypoint**: Individual waypoint representation

### Utils Layer
- **Logger**: Comprehensive logging system
- **SafetyUtils**: Flight safety validation
- **LocationValidator**: GPS coordinate validation

## Error Handling

The app includes comprehensive error handling for:
- Connection failures
- Mission upload errors
- Execution problems
- Safety violations
- Hardware issues

## Development Notes

### Thread Safety
- All UI updates are performed on the main thread
- Background operations use appropriate queues
- Delegate callbacks are main-thread safe

### Memory Management
- Proper use of weak references to prevent retain cycles
- Automatic cleanup of observers and timers
- Efficient resource management

### Testing
- Unit tests for core logic
- Integration tests for drone communication
- UI tests for user interactions

## Support

For issues related to:
- **DJI SDK**: Check [DJI Developer Documentation](https://developer.dji.com/doc/)
- **iOS Development**: Refer to [Apple Developer Documentation](https://developer.apple.com/documentation/)

## License

This project is provided as-is for educational and development purposes. Please ensure compliance with local drone regulations and DJI's terms of service.

## Safety Warning

⚠️ **IMPORTANT**: Always follow local aviation regulations and safety guidelines when operating drones. This software is intended for educational purposes and should be thoroughly tested in a safe environment before any real-world use.
