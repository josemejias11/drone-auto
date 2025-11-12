# 📁 DroneAuto Project Structure

## Overview
This document provides a comprehensive overview of the DroneAuto project structure, file organization, and architectural decisions.

## Project Layout

```
drone-auto/
├── DroneAutoApp/                      # Main iOS application directory
│   ├── Configuration/                 # App configuration files
│   │   └── Info.plist                # iOS app configuration
│   └── Source/                        # Swift source code
│       ├── AppDelegate.swift         # App lifecycle management
│       ├── SceneDelegate.swift       # Scene lifecycle (iOS 13+)
│       ├── Controllers/              # View controllers
│       │   └── MainViewController.swift
│       ├── Models/                   # Data models
│       │   ├── DroneModels.swift    # Drone status & connection models
│       │   ├── FlightPlan.swift     # Flight plan data structure
│       │   └── MissionFormat.swift  # JSON mission format models
│       ├── Services/                 # Business logic services
│       │   ├── DroneService.swift           # DJI SDK integration
│       │   ├── MissionFileManager.swift     # Files app integration
│       │   └── PersonalMissionManager.swift # Mission management (1,233 LOC)
│       └── Utils/                    # Utility classes
│           ├── HardwareConfiguration.swift  # Device & drone specs
│           ├── Logger.swift                 # Logging utility
│           └── SafetyUtils.swift           # Safety validation
│
├── LegacyDroneController.swift       # Legacy reference code (deprecated)
├── sample_mission.json               # Example mission file
│
├── Configuration Files/
│   ├── Podfile                       # CocoaPods dependencies
│   ├── Package.swift                 # Swift Package Manager (reference only)
│   └── .gitignore                    # Git ignore rules
│
└── Documentation/
    ├── README.md                     # Main project README
    ├── DEVELOPMENT_GUIDE.md          # Development workflow guide
    ├── DJI_TRANSLATION_GUIDE.md      # DJI SDK integration guide
    ├── JSON_IMPORT_STATUS.md         # JSON import system documentation
    ├── JSON_MISSION_FORMAT.md        # Mission format specification
    └── PROJECT_STRUCTURE.md          # This file
```

## Core Components

### 1. Services Layer (Business Logic)

**DroneService.swift** (287 LOC)
- DJI SDK integration and communication
- Drone connection management
- Mission upload, start, pause, stop operations
- Real-time status updates
- Implements singleton pattern (`DroneService.shared`)

**PersonalMissionManager.swift** (1,233 LOC)
- Mission template generation (basic test, grid survey, perimeter)
- JSON mission import/export with validation
- DJI mission translation (FlightPlan → DJIWaypointMission)
- Costa Rica regulatory compliance validation
- Mission file persistence

**MissionFileManager.swift** (254 LOC)
- Files app integration
- Mission save/load operations
- Document picker integration
- Mission export and sharing

### 2. Models Layer (Data Structures)

**FlightPlan.swift** (83 LOC)
- Core flight plan data structure
- Waypoint model with coordinates, altitude, gimbal settings
- Flight plan validation
- Distance and time calculations

**MissionFormat.swift** (224 LOC)
- JSON-serializable mission format
- Comprehensive waypoint actions support
- Safety limits configuration
- Conversion extensions (FlightPlan ↔ JSONMission)

**DroneModels.swift** (41 LOC)
- Connection state enum
- Mission state enum
- Drone status struct
- DroneStatusDelegate protocol

### 3. Controllers Layer (UI)

**MainViewController.swift** (632 LOC)
- Main UI with mission control buttons
- Drone status display (battery, GPS, altitude)
- File operations UI (save, load, export)
- Mission template creation
- Implements DroneStatusDelegate

### 4. Utils Layer (Utilities)

**HardwareConfiguration.swift** (165 LOC)
- iPad Pro 11" M2 specifications
- DJI Mavic 2 Classic specifications
- Costa Rica regulatory settings
- Development configuration presets

**Logger.swift** (80 LOC)
- Multi-level logging (debug, info, warning, error)
- Emoji indicators for quick identification
- File/line/function tracking
- NSObject logging extensions

**SafetyUtils.swift** (103 LOC)
- Location validation
- Flight plan safety checks
- Battery level warnings
- GPS signal validation

### 5. App Lifecycle

**AppDelegate.swift** (68 LOC)
- DJI SDK initialization
- App registration handling
- Scene session lifecycle (iOS 13+)

**SceneDelegate.swift** (40 LOC)
- Window scene management
- View controller initialization
- Scene lifecycle callbacks

## Architecture Patterns

### Design Patterns Used
- **Singleton**: Services (DroneService, PersonalMissionManager, Logger)
- **Delegation**: Drone status updates, file picker
- **MVC**: View controllers, models, and service layer separation
- **Result Type**: Error handling for async operations
- **Builder Pattern**: Mission template creation

### Key Architectural Decisions

1. **Service Layer Separation**
   - DroneService: Hardware communication only
   - PersonalMissionManager: Mission logic and validation
   - MissionFileManager: File I/O operations

2. **Model Conversions**
   - Internal FlightPlan model for app logic
   - JSONMission for persistence and import/export
   - DJIWaypointMission for SDK communication

3. **Safety-First Approach**
   - Multiple validation layers
   - Costa Rica regulatory compliance built-in
   - Hardware-specific safety limits

## File Statistics

| Component | Files | Lines of Code |
|-----------|-------|---------------|
| Services | 3 | ~1,774 |
| Models | 3 | ~348 |
| Controllers | 1 | ~632 |
| Utils | 3 | ~348 |
| App Lifecycle | 2 | ~108 |
| **Total** | **12** | **~3,349** |

## Dependencies

### CocoaPods (Podfile)
- **DJI-SDK-iOS** (~4.16): DJI drone SDK
- **CocoaLumberjack/Swift** (~3.0): Enhanced logging (optional)

### iOS Requirements
- **Platform**: iOS 15.0+
- **Target Device**: iPad Pro 11" M2
- **Hardware**: DJI Mavic 2 Classic

## Configuration Files

### Info.plist
Located in `DroneAutoApp/Configuration/Info.plist`
- App permissions (location, camera, etc.)
- DJI SDK configuration
- Files app integration settings

### Podfile
- iOS deployment target: 15.0
- DJI SDK integration
- Bitcode disabled (required for DJI SDK)

### .gitignore
- Xcode project files
- CocoaPods artifacts
- API keys and secrets
- Build artifacts

## Code Quality Features

✅ **Type Safety**: Comprehensive use of Swift enums and structs
✅ **Error Handling**: Result types for async operations
✅ **Documentation**: Inline comments and markdown guides
✅ **Safety Validation**: Multiple validation layers
✅ **Logging**: Comprehensive debug logging
✅ **Modularity**: Clear separation of concerns

## Development Workflow

1. **Mission Creation**: Use PersonalMissionManager templates
2. **Validation**: Automatic safety and regulatory checks
3. **Persistence**: Save to Files app for reuse
4. **Upload**: Convert to DJI format and upload
5. **Execution**: Monitor through DroneService callbacks

## Future Improvements Recommended

- [ ] Add unit tests for mission validation
- [ ] Add UI tests for main workflows
- [ ] Create API key configuration file (not committed)
- [ ] Add Xcode project file
- [ ] Implement offline mission caching
- [ ] Add mission history/analytics
- [ ] Create custom mission builder UI

## Notes

- **LegacyDroneController.swift**: Contains original script for reference only
- **API Key**: Must be configured in AppDelegate.swift (line 13)
- **Costa Rica Compliance**: All missions validate against 122m altitude limit
- **Files App**: Missions saved to Documents/DroneAutoMissions/

---

**Last Updated**: 2025-11-12
**Project Version**: 1.0
**Target Platform**: iOS 15.0+ (iPad Pro M2)
