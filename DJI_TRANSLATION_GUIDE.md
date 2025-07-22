# 🚁 FlightPlan to DJI Mission Translation System

## Overview

The DroneAuto project now includes a complete translation system that converts your custom `FlightPlan` and `JSONMission` formats into DJI's `DJIWaypointMission` format for actual drone execution.

## 🔄 Translation Flow

```
JSON Mission → FlightPlan → DJIWaypointMission → Drone Execution
     ↑              ↑              ↑                    ↑
  Files App    Internal Format   DJI SDK Format    Real Flight
```

## 🛠️ Implementation Components

### **1. PersonalMissionManager Translation Methods**

#### **Basic Translation:**
```swift
let result = PersonalMissionManager.shared.translateToDJIMission(flightPlan)
switch result {
case .success(let djiMission):
    // Ready for DJI SDK
case .failure(let error):
    // Handle translation error
}
```

#### **Enhanced JSON Translation:**
```swift
let result = PersonalMissionManager.shared.createEnhancedDJIMission(from: jsonMission)
// Includes all JSON actions, settings, and metadata
```

### **2. DroneService Integration**

The `DroneService` automatically uses the translation system:

```swift
// Upload FlightPlan
droneService.uploadMission(flightPlan) { result in
    // Internally translates FlightPlan → DJIWaypointMission
}

// Upload JSON Mission (with enhanced features)
droneService.uploadJSONMission(jsonMission) { result in
    // Internally translates JSON → DJIWaypointMission with full action support
}
```

## 🎯 Translation Features

### **Mission Settings Translation**
| FlightPlan/JSON | DJI Equivalent | Notes |
|-----------------|----------------|--------|
| `maxFlightSpeed` | `maxFlightSpeed` | Validated 1-15 m/s for DJI |
| `autoFlightSpeed` | `autoFlightSpeed` | Must be ≤ maxFlightSpeed |
| `finishedAction` | `finishedAction` | "goHome" → .goHome, etc. |
| `headingMode` | `headingMode` | "auto" → .auto, etc. |
| `exitMissionOnRCSignalLost` | `exitMissionOnRCSignalLost` | Safety setting |
| `repeatTimes` | `repeatTimes` | 1-10 repetitions |

### **Waypoint Translation**
| FlightPlan/JSON | DJI Equivalent | Validation |
|-----------------|----------------|------------|
| `coordinate` | `coordinate` | GPS validation |
| `altitude` | `altitude` | 2-120m for DJI |
| `heading` | `heading` | 0-359° |
| `gimbalPitch` | DJIWaypointAction | -90° to 30° |
| `cornerRadiusInMeters` | `cornerRadiusInMeters` | Smooth turns |
| `speed` | Per-waypoint override | 0.1-20 m/s |

### **Action Translation**
| JSON Action | DJI Action Type | Parameters |
|-------------|-----------------|------------|
| `"takePhoto"` | `.shootPhoto` | None |
| `"startRecording"` | `.startRecord` | Duration in parameters |
| `"stopRecording"` | `.stopRecord` | None |
| `"rotateGimbal"` | `.rotateGimbal` | Pitch angle |
| `"rotateAircraft"` | `.rotateAircraft` | Heading angle |

## 🛡️ Validation & Safety

### **Pre-Translation Validation**
✅ **Mission Level:**
- 1-99 waypoint limit
- Non-empty mission name
- Valid settings ranges

✅ **Waypoint Level:**
- GPS coordinate validity
- Altitude within DJI limits (2-120m)
- Heading range (0-359°)
- Speed limits (0.1-20 m/s)

✅ **Action Level:**
- Valid action types
- Required parameters present
- Parameter value ranges

### **Post-Translation Validation**
✅ **DJI Mission Validation:**
- DJI waypoint count limits
- DJI speed restrictions
- DJI-specific parameter ranges

### **Costa Rica Compliance**
✅ **Regulatory Checks:**
- Maximum altitude: 150m (120m DJI limit is within legal bounds)
- Geofencing enforcement
- Battery and GPS signal requirements

## 📱 User Interface Integration

### **Automatic Translation in UI**
When you tap "Upload Mission" in the app:

1. **Basic FlightPlan Upload:**
   - Uses `translateToDJIMission()` 
   - Includes basic waypoints, speeds, actions
   - Automatic photo capture at waypoints

2. **Enhanced JSON Upload** (when loading from Files):
   - Uses `createEnhancedDJIMission()` 
   - Preserves all JSON actions and settings
   - Advanced gimbal control and aircraft rotation

### **Error Handling**
The UI provides detailed error messages for translation failures:

```swift
// Example error messages:
"Waypoint 3: Altitude must be between 2-120m for DJI"
"Invalid action type 'customAction' at waypoint 2"
"Max flight speed must be 1-15 m/s for DJI drones"
```

## 🔧 Advanced Features

### **Enhanced JSON Mission Translation**
The `createEnhancedDJIMission()` method provides additional features:

```swift
// Automatic photo actions
let photoAction = DJIWaypointAction(actionType: .shootPhoto, parameter: 0)

// Gimbal control from JSON
if let gimbalPitch = jsonWaypoint.gimbalPitch {
    let gimbalAction = DJIWaypointAction(actionType: .rotateGimbal, parameter: Int(gimbalPitch))
    djiWaypoint.add(gimbalAction)
}

// Video recording with duration
let recordAction = DJIWaypointAction(actionType: .startRecord, parameter: 0)
```

### **Safety Enhancements**
- **Geofencing**: JSON safety limits are enforced during translation
- **Battery Monitoring**: Mission upload checks current battery level
- **GPS Requirements**: Ensures GPS signal strength before upload
- **Distance Limits**: Validates waypoint distances from home base

## 🚀 Example Usage

### **Complete Workflow Example:**

```swift
// 1. Create or load JSON mission
let jsonMission = PersonalMissionManager.shared.createBasicTestJSONMission()

// 2. Translate to DJI format (automatically done by DroneService)
droneService.uploadJSONMission(jsonMission) { result in
    switch result {
    case .success:
        print("Mission translated and uploaded successfully!")
        
        // 3. Execute mission
        droneService.startMission { result in
            // Mission is now running on drone
        }
        
    case .failure(let error):
        print("Translation or upload failed: \(error)")
    }
}
```

### **Direct Translation (Advanced):**

```swift
// Manual translation for custom workflows
let translationResult = PersonalMissionManager.shared.translateToDJIMission(flightPlan)

switch translationResult {
case .success(let djiMission):
    // djiMission is ready for DJI SDK
    missionOperator.uploadMission(djiMission) { error in
        // Handle DJI upload result
    }
    
case .failure(let error):
    print("Translation failed: \(error.localizedDescription)")
}
```

## 🎯 Key Benefits

1. **Seamless Integration**: Your JSON missions automatically work with DJI drones
2. **Enhanced Safety**: Multiple validation layers prevent unsafe missions
3. **Full Feature Support**: All JSON actions translate to DJI equivalents
4. **Error Transparency**: Clear error messages for troubleshooting
5. **Costa Rica Compliant**: Built-in regulatory compliance
6. **Development Friendly**: Easy testing with sample missions

## 🔍 Debugging Translation Issues

### **Common Issues and Solutions:**

**"Altitude must be between 2-120m"**
- DJI has stricter altitude limits than our internal validation
- Adjust waypoint altitudes in your JSON missions

**"Invalid action type"**
- Ensure action types match supported list
- Check parameter formatting in JSON

**"Distance between waypoints too large"**
- Split long distances into multiple shorter segments
- Maximum 1km between consecutive waypoints

The translation system ensures your creative mission designs work seamlessly with DJI's hardware while maintaining safety and regulatory compliance! 🚁✨
