# 🚁 Jose's Drone Development Workspace

Personal development environment for custom drone flight automation using iPad Pro 11" M2 and DJI Mavic 2 Classic.

## 🎯 Purpose

Build, test, and deploy custom flight functionalities for:
- Property surveying and mapping
- Photography automation projects  
- Routine inspection flights
- Algorithm development and testing

## 🛠️ Setup

**Hardware:**
- 📱 iPad Pro 11" M2 (development device)
- 🚁 DJI Mavic 2 Classic (test drone)
- 🌍 Costa Rica operations (compliant)

**Software:**
- iOS app using DJI Mobile SDK
- Swift development with safety-first approach
- Real-time flight monitoring and control

## 🚀 Quick Start

### 1. Development Environment
```bash
git clone https://github.com/josemejias11/drone-auto.git
cd drone-auto
```

### 2. Create iOS Project
1. Open Xcode and create new iOS project
2. Copy `DroneAutoApp/Source/` files to your project
3. Add `DroneAutoApp/Configuration/Info.plist` settings
4. Download and add DJI Mobile SDK
5. Configure your DJI app key

### 3. Ready-to-Use Mission Templates

**Basic Test Mission** - 4-waypoint pattern for system validation:
```swift
let testMission = PersonalMissionManager.shared.createBasicTestMission()
// Creates a 100m x 100m square pattern at safe test altitude
// Includes automated gimbal positioning and safety validation
```

**Grid Survey Mission** - Optimized snake pattern for mapping:
```swift
let survey = PersonalMissionManager.shared.createGridSurveyMission(
    center: CLLocationCoordinate2D(latitude: 10.323520, longitude: -84.430511),
    gridSize: 0.002, // ~200m coverage area
    altitude: 80.0,
    overlapPercentage: 75 // For photogrammetry
)
// Generates efficient back-and-forth pattern with configurable overlap
```

**Perimeter Inspection** - Angled gimbal inspection flight:
```swift
let perimeter = PersonalMissionManager.shared.createPerimeterMission(
    corners: myPropertyCorners,
    altitude: 60.0
)
// Automated gimbal angling for comprehensive property inspection
// Includes corner optimization and obstacle avoidance planning
```

### 4. Advanced Features
- **JSON Mission Persistence**: Save/load missions through iOS Files app
- **Costa Rica Compliance**: Built-in 122m altitude limits and regulations
- **iPad Pro M2 Optimization**: ProMotion 120Hz, Metal acceleration, ARM64
- **Multi-level Logging**: Development-friendly debugging with emoji indicators
- **Smart Validation**: Comprehensive safety checks before every flight

## 📁 Project Structure

**Complete iOS Development Environment:**
```
DroneAutoApp/
├── Source/
│   ├── Services/
│   │   ├── DroneService.swift              # DJI SDK integration & communication
│   │   └── PersonalMissionManager.swift    # 3 mission templates with validation
│   ├── Models/
│   │   ├── FlightPlan.swift               # Codable mission persistence
│   │   └── DroneModels.swift              # Real-time status management
│   ├── Controllers/
│   │   └── MainViewController.swift        # iPad Pro optimized interface
│   └── Utils/
│       ├── HardwareConfiguration.swift     # iPad M2 + Mavic 2 specs
│       ├── SafetyUtils.swift              # Costa Rica compliance validation
│       └── Logger.swift                   # Multi-level development logging
├── Configuration/
│   ├── Info.plist                         # iPad Pro permissions & settings
│   └── Podfile                           # DJI Mobile SDK v4.16.4 integration
└── AppDelegate.swift                      # DJI SDK initialization
```

**Key Capabilities:**
- ✅ **322-line PersonalMissionManager**: Complete mission system with validation
- ✅ **JSON Persistence**: Save/load through iOS Files app integration
- ✅ **Multi-level Logging**: Emoji-based debugging for rapid development iteration
- ✅ **Hardware Optimization**: iPad Pro M2 ProMotion + Metal acceleration
- ✅ **Safety Validation**: Costa Rica regulations + comprehensive pre-flight checks

## 🧪 Development Workflow

**Rapid Development & Testing Cycle:**
1. **Code**: Develop on iPad Pro M2 with intelligent autocomplete
2. **Validate**: Comprehensive safety checks with Costa Rica compliance
3. **Simulate**: Test mission logic with built-in validation system
4. **Deploy**: Upload to Mavic 2 Classic with real-time monitoring
5. **Analyze**: Review multi-level logs with emoji indicators for quick debugging
6. **Iterate**: JSON mission persistence for rapid experimentation

**Mission Development Examples:**
```swift
// Create and validate a mission
let mission = PersonalMissionManager.shared.createGridSurveyMission(...)
let isValid = PersonalMissionManager.shared.validateForPersonalSetup(mission)

// Save for later testing
PersonalMissionManager.shared.saveMission(mission, name: "property_survey_v2")

// Real-time logging during development
Logger.shared.info("Mission validated successfully ✅")
Logger.shared.debug("Generated \(mission.waypoints.count) waypoints 📍")
```

## 🛡️ Safety Features

**Multi-Layer Safety System:**
- 🇨🇷 **Costa Rica Compliance**: Automatic 122m altitude enforcement
- 🚁 **Mavic 2 Limits**: 8km range validation with 31-minute flight time tracking
- 🔋 **Smart Battery**: 30% minimum with landing buffer calculations
- 📡 **GPS Validation**: Level 4+ signal strength requirements
- 🏠 **Auto Return-to-Home**: Triggered on critical errors or low battery
- 📊 **Real-time Monitoring**: Live telemetry with immediate alerts
- ⚠️ **Pre-flight Validation**: Comprehensive mission safety checks
- 📱 **iPad Integration**: Hardware-optimized performance monitoring

**Advanced Safety Features:**
```swift
// Built-in validation before every flight
let validationResult = PersonalMissionManager.shared.validateForPersonalSetup(mission)
// Checks: altitude limits, range limits, battery requirements, GPS signal
// Costa Rica specific: 122m max altitude, no-fly zone awareness
```

## 📖 Documentation

- **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)**: Detailed development workflows and examples
- **[LICENSE](LICENSE)**: Educational use terms and safety requirements

## 🔧 Personal Configuration

**Quick Customization Points:**
```swift
// 1. Update test locations in PersonalMissionManager.swift
private static let testLocations = [
    CLLocationCoordinate2D(latitude: 10.323520, longitude: -84.430511), // Your location
    // Add more test sites...
]

// 2. Configure DJI app key in AppDelegate.swift  
let appKey = "YOUR_DJI_APP_KEY_HERE" // From DJI Developer Account

// 3. Adjust hardware preferences in HardwareConfiguration.swift
static let preferredAltitude: Double = 80.0 // Your preferred flight altitude
static let surveyOverlap: Double = 75.0 // Photo overlap percentage
```

**Mission Template Customization:**
- **Basic Test**: Modify square pattern size and waypoint count
- **Grid Survey**: Adjust overlap percentage and flight speed optimization  
- **Perimeter Inspection**: Configure gimbal angles and corner approach patterns
- **JSON Storage**: Missions automatically saved to iOS Files app for sharing

**Development Features:**
- Multi-level logging with emoji indicators for rapid debugging
- iPad Pro M2 optimization with ProMotion and Metal acceleration
- Real-time validation system with Costa Rica regulatory compliance
- Comprehensive mission persistence and sharing through Files app integration

---

**Happy coding and safe flying! 🚁✨**
