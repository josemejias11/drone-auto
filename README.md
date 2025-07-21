# 🚁 DJI Drone Automation App

[![iOS](https://img.shields.io/badge/iOS-13.0+-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.8+-orange.svg)](https://swift.org/)
[![DJI SDK](https://img.shields.io/badge/DJI_SDK-4.16+-red.svg)](https://developer.dji.com/)
[![License](https://img.shields.io/badge/License-Educational-green.svg)](LICENSE)

A comprehensive iOS application for automating DJI drone flights using waypoint missions. Built with modern iOS architecture patterns and comprehensive safety features.

## 🎯 Features

- ✈️ **Autonomous Flight Control**: Create and execute waypoint missions
- 📡 **Real-time Monitoring**: Live status updates for battery, GPS, altitude
- 🛡️ **Safety Checks**: Comprehensive pre-flight validation
- 🎯 **Mission Management**: Upload, start, pause, resume, and stop missions
- 📱 **Modern UI**: Clean, intuitive interface for mission control
- 🔄 **Real-time Updates**: Delegate-based status monitoring
- 📝 **Professional Logging**: Multi-level logging system
- 🛡️ **Error Handling**: Comprehensive error management

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

## 🚀 Quick Start

### Clone the Repository

```bash
git clone https://github.com/josemejias11/drone-auto.git
cd drone-auto
```

### Prerequisites

- macOS 12.0+ with Xcode 14.0+
- iOS 13.0+ target device (DJI SDK requires physical device)
- DJI Developer Account ([Register here](https://developer.dji.com))
- Compatible DJI Drone (Mavic series, Phantom series, etc.)

## 📋 Setup Instructions

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

## 🏗️ Code Architecture

### 🔧 Services Layer
- **DroneService**: Centralized drone communication and mission management
- Singleton pattern for global access
- Delegate pattern for status updates
- Thread-safe operations with proper queue management

### 📊 Models Layer
- **FlightPlan**: Encapsulates waypoints and flight parameters with validation
- **DroneModels**: Status and state management with safety checks
- **Waypoint**: Individual waypoint representation with coordinate validation

### 🛠️ Utils Layer
- **Logger**: Comprehensive logging system with multiple levels
- **SafetyUtils**: Flight safety validation and boundary checking
- **LocationValidator**: GPS coordinate validation and distance calculations

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

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Development Guidelines

- Follow Swift style guidelines
- Add unit tests for new features
- Update documentation for API changes
- Ensure all safety checks are maintained

## 📞 Support

For issues related to:
- **DJI SDK**: Check [DJI Developer Documentation](https://developer.dji.com/doc/)
- **iOS Development**: Refer to [Apple Developer Documentation](https://developer.apple.com/documentation/)
- **Project Issues**: Create an issue in this repository

## 📄 License

This project is provided as-is for educational and development purposes. Please ensure compliance with local drone regulations and DJI's terms of service.

## ⚠️ Safety Warning

**IMPORTANT**: Always follow local aviation regulations and safety guidelines when operating drones. This software is intended for educational purposes and should be thoroughly tested in a safe environment before any real-world use.

### Legal Requirements
- ✅ Check local drone registration requirements
- ✅ Obtain necessary flight permissions/licenses
- ✅ Respect no-fly zones and airspace restrictions
- ✅ Maintain visual line of sight with your drone
- ✅ Follow manufacturer's safety guidelines

---

<div align="center">

**Made with ❤️ for the drone development community**

[Report Bug](https://github.com/josemejias11/drone-auto/issues) · [Request Feature](https://github.com/josemejias11/drone-auto/issues) · [Documentation](https://github.com/josemejias11/drone-auto/wiki)

</div>
