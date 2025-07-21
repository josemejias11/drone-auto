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
```swift
// Basic test flight
let testMission = PersonalMissionManager.shared.createBasicTestMission()

// Grid survey for mapping
let survey = PersonalMissionManager.shared.createGridSurveyMission(
    center: CLLocationCoordinate2D(latitude: 10.323520, longitude: -84.430511),
    gridSize: 0.002, // ~200m coverage
    altitude: 80.0
)

// Property perimeter inspection
let perimeter = PersonalMissionManager.shared.createPerimeterMission(
    corners: myPropertyCorners,
    altitude: 60.0
)
```

## 📁 Project Structure

```
DroneAutoApp/Source/
├── Services/
│   ├── DroneService.swift              # Core drone communication
│   └── PersonalMissionManager.swift    # Pre-built mission templates
├── Models/
│   ├── FlightPlan.swift               # Mission and waypoint models
│   └── DroneModels.swift              # Status and state management  
├── Controllers/
│   └── MainViewController.swift        # iPad-optimized UI
└── Utils/
    ├── HardwareConfiguration.swift     # Mavic 2 + iPad Pro specs
    ├── SafetyUtils.swift              # Flight validation
    └── Logger.swift                   # Development logging
```

## 🧪 Development Workflow

1. **Code**: Develop missions and algorithms on iPad
2. **Validate**: Run safety checks and simulations
3. **Test**: Deploy to Mavic 2 in safe test area
4. **Analyze**: Review flight logs and performance
5. **Iterate**: Refine based on real-world results

## 🛡️ Safety Features

- Costa Rica altitude limits (122m max)
- Mavic 2 range validation (8km max)
- Battery level monitoring (30% minimum)
- GPS signal validation (level 4+ required)
- Automated return-to-home on errors
- Real-time status monitoring

## 📖 Documentation

- **[DEVELOPMENT_GUIDE.md](DEVELOPMENT_GUIDE.md)**: Detailed development workflows and examples
- **[LICENSE](LICENSE)**: Educational use terms and safety requirements

## 🔧 Personal Configuration

Update these for your specific needs:
- Test locations in `PersonalMissionManager.testLocations`
- DJI app key in `AppDelegate.swift`
- Local coordinates and altitude preferences
- Custom mission templates and flight patterns

---

**Happy coding and safe flying! 🚁✨**
