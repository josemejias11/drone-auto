# 📁 Project Structure

## 🏗️ Architecture Overview

```
drone-auto/
├── 🚁 DroneAutoApp/                    # Main iOS Application
│   ├── 📱 Source/                      # Application Source Code
│   │   ├── 🚀 AppDelegate.swift        # App lifecycle & DJI SDK setup
│   │   ├── 📱 SceneDelegate.swift      # Scene management (iOS 13+)
│   │   ├── 🎮 Controllers/             # View Controllers
│   │   │   └── MainViewController.swift     # Main UI with drone controls
│   │   ├── 📊 Models/                  # Data Models
│   │   │   ├── FlightPlan.swift             # Flight planning with validation
│   │   │   └── DroneModels.swift            # Drone status & state management
│   │   ├── ⚙️ Services/                # Business Logic Layer
│   │   │   └── DroneService.swift           # Core drone communication service
│   │   ├── 🖼️ Views/                   # Custom UI Components
│   │   │   └── (Future custom views)
│   │   └── 🛠️ Utils/                   # Utility Classes
│   │       ├── Logger.swift                 # Professional logging system
│   │       └── SafetyUtils.swift            # Safety validation utilities
│   ├── 📦 Resources/                   # App Resources
│   │   └── Assets/                          # Images, icons, etc.
│   └── ⚙️ Configuration/               # App Configuration
│       └── Info.plist                       # App metadata & permissions
├── 📋 GitHub Integration/              # Repository Management
│   ├── 🐛 .github/ISSUE_TEMPLATE/     # Issue Templates
│   │   ├── bug_report.yml                   # Bug reporting with drone specifics
│   │   └── feature_request.yml              # Feature requests with priorities
│   └── ⚡ .github/workflows/          # GitHub Actions
│       └── ci.yml                           # Continuous integration
├── 📚 Documentation/                  # Project Documentation
│   ├── 📖 README.md                   # Main project documentation
│   ├── 🤝 CONTRIBUTING.md             # Contribution guidelines
│   └── 📄 LICENSE                     # Educational use license
├── 🔧 Configuration Files/            # Project Setup
│   ├── 📦 Package.swift               # Swift Package Manager
│   ├── 🙈 .gitignore                  # Git ignore rules
│   └── 🚁 import DJISDK.swift         # Original script (reference)
└── 🔄 Version Control/                # Git Management
    └── .git/                               # Git repository data
```

## 🎯 Key Components

### 🚁 **DroneService** (Singleton)
- **Purpose**: Central hub for all drone communications
- **Features**: Mission management, status monitoring, safety checks
- **Pattern**: Singleton with delegate callbacks
- **Thread Safety**: All operations are thread-safe with proper queue management

### 📊 **FlightPlan & Models**
- **FlightPlan**: Complete mission definition with validation
- **Waypoint**: Individual waypoint with coordinate validation  
- **DroneStatus**: Real-time drone state and health monitoring
- **Safety**: Built-in validation for all flight parameters

### 🎮 **MainViewController**
- **Purpose**: Primary user interface for drone control
- **Features**: Real-time status, mission control, safety monitoring
- **Architecture**: Delegate pattern for updates, modern iOS UI patterns
- **Safety**: User-friendly safety warnings and status indicators

### 🛠️ **Utils Layer**
- **Logger**: Multi-level logging (debug, info, warning, error)
- **SafetyUtils**: Comprehensive flight safety validation
- **LocationValidator**: GPS coordinate and boundary validation

## 🔄 Data Flow

```
User Input → MainViewController → DroneService → DJI SDK → Drone
     ↑                                ↓
Status Updates ← Delegate Pattern ← Status Monitoring
```

## 🛡️ Safety Architecture

```
Flight Request → Safety Validation → DJI SDK → Hardware
                      ↓
                 [Battery Check]
                 [GPS Validation]  
                 [Coordinate Bounds]
                 [Altitude Limits]
                 [Speed Validation]
                      ↓
                 [Approved/Rejected]
```

## 📱 UI Architecture

```
MainViewController (Root)
├── Connection Status Display
├── Drone Status Monitoring
│   ├── Battery Level (with color coding)
│   ├── GPS Signal Strength
│   └── Current Altitude
├── Mission Control Panel
│   ├── Upload Mission Button
│   ├── Start/Pause/Resume Controls
│   └── Stop Mission Button
└── Real-time Status Updates
```

## 🔧 Development Patterns

- **MVCS**: Model-View-Controller-Service architecture
- **Delegation**: For status updates and event handling  
- **Singleton**: For drone service management
- **Protocol-Oriented**: Extensible and testable design
- **Thread-Safe**: Proper queue management for UI updates
- **Memory Safe**: Weak references to prevent retain cycles

## 🚀 Future Extensibility

The architecture supports easy addition of:
- Custom UI components in `Views/`
- Additional drone models in `Models/`
- New utility functions in `Utils/`
- Advanced flight planning features
- Real-time telemetry visualization
- Mission recording and playback
