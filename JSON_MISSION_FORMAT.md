# 📄 JSON Mission Format Guide

## Overview

The DroneAuto app now supports a standardized JSON mission format that can be saved to and loaded from the Files app on your iPad. This allows you to:

- **Create missions externally** using text editors or mission planning tools
- **Share missions** with other users or devices
- **Version control** your mission plans
- **Backup missions** to cloud storage through Files app
- **Edit missions** in detail using any JSON editor

## 📍 Files App Location

Your missions are stored in:
```
Files → On My iPad → DroneAuto → DroneAutoMissions/
```

## 📋 JSON Mission Structure

### Basic Structure
```json
{
  "metadata": { /* Mission information */ },
  "settings": { /* Flight parameters */ },
  "waypoints": [ /* Array of waypoint objects */ ],
  "safetyLimits": { /* Safety boundaries */ }
}
```

### Complete Example
```json
{
  "metadata": {
    "name": "Property Survey Mission",
    "description": "Complete aerial survey of the north property",
    "createdDate": "2025-07-22T12:00:00Z",
    "modifiedDate": "2025-07-22T12:30:00Z",
    "version": "1.0",
    "author": "Jose",
    "tags": ["survey", "property", "mapping"]
  },
  "settings": {
    "maxFlightSpeed": 15.0,
    "autoFlightSpeed": 10.0,
    "finishedAction": "goHome",
    "headingMode": "auto",
    "gotoFirstWaypointMode": "safely",
    "exitMissionOnRCSignalLost": true,
    "repeatTimes": 1
  },
  "waypoints": [
    {
      "coordinate": {
        "latitude": 10.323520,
        "longitude": -84.430511
      },
      "altitude": 80.0,
      "heading": null,
      "gimbalPitch": -60.0,
      "speed": 8.0,
      "cornerRadiusInMeters": 0.2,
      "turnMode": "clockwise",
      "actionTimeoutInSeconds": 60.0,
      "actionRepeatTimes": 1,
      "actions": [
        {
          "type": "takePhoto",
          "parameters": null
        }
      ]
    }
  ],
  "safetyLimits": {
    "maxAltitude": 120.0,
    "maxDistanceFromHome": 500.0,
    "minBatteryLevel": 20,
    "minGPSSignalLevel": 3,
    "geofenceCenter": {
      "latitude": 10.323520,
      "longitude": -84.430511
    },
    "geofenceRadius": 400.0
  }
}
```

## 🔧 Field Descriptions

### Metadata Section
| Field | Type | Description |
|-------|------|-------------|
| `name` | String | Mission display name |
| `description` | String? | Optional detailed description |
| `createdDate` | Date | ISO8601 timestamp of creation |
| `modifiedDate` | Date | ISO8601 timestamp of last modification |
| `version` | String | Mission format version |
| `author` | String | Mission creator name |
| `tags` | [String] | Array of category tags |

### Settings Section
| Field | Type | Description |
|-------|------|-------------|
| `maxFlightSpeed` | Float | Maximum flight speed in m/s |
| `autoFlightSpeed` | Float | Automatic flight speed in m/s |
| `finishedAction` | String | Action when mission completes: "goHome", "autoLand", "noAction", "goFirstWaypoint" |
| `headingMode` | String | Drone heading control: "auto", "usingInitialDirection", "controlByRemoteController", "usingWaypointHeading" |
| `gotoFirstWaypointMode` | String | "safely" or "pointToPoint" |
| `exitMissionOnRCSignalLost` | Bool | Exit mission if remote control signal is lost |
| `repeatTimes` | Int | Number of times to repeat the mission |

### Waypoint Section
| Field | Type | Description |
|-------|------|-------------|
| `coordinate.latitude` | Double | GPS latitude (-90 to 90) |
| `coordinate.longitude` | Double | GPS longitude (-180 to 180) |
| `altitude` | Float | Height above takeoff point in meters |
| `heading` | Float? | Drone heading in degrees (0-360), null for auto |
| `gimbalPitch` | Float? | Camera angle in degrees (-90 to 30) |
| `speed` | Float? | Override speed for this waypoint |
| `cornerRadiusInMeters` | Float | Turn radius at waypoint |
| `turnMode` | String | "clockwise" or "counterClockwise" |
| `actions` | [Action] | Array of actions to perform at waypoint |

### Action Types
| Type | Description | Parameters |
|------|-------------|------------|
| `takePhoto` | Capture a single photo | none |
| `startRecording` | Start video recording | `{"duration": "10"}` |
| `stopRecording` | Stop video recording | none |
| `rotateGimbal` | Rotate camera gimbal | `{"pitch": "-45", "yaw": "0"}` |
| `rotateAircraft` | Rotate drone | `{"heading": "90"}` |

### Safety Limits Section
| Field | Type | Description |
|-------|------|-------------|
| `maxAltitude` | Float | Maximum allowed altitude in meters |
| `maxDistanceFromHome` | Float | Maximum distance from takeoff point |
| `minBatteryLevel` | Int | Minimum battery percentage (0-100) |
| `minGPSSignalLevel` | Int | Minimum GPS signal quality (0-5) |
| `geofenceCenter` | Coordinate? | Center point of geofence |
| `geofenceRadius` | Float? | Geofence radius in meters |

## 🚀 Using the App Features

### Save Mission to Files
1. Create or load a mission in the app
2. Tap "Save to Files"
3. Mission is saved as JSON in Files app
4. Access via Files → On My iPad → DroneAuto → DroneAutoMissions

### Load Mission from Files
1. Tap "Load from Files"
2. Browse and select a .json mission file
3. Mission loads into the app automatically

### Export Mission
1. Create or load a mission
2. Tap "Export Mission"
3. Share via AirDrop, Messages, Mail, etc.

### Create Sample Missions
1. Tap "Create Sample"
2. Choose from pre-built templates:
   - Basic Test Mission (4-waypoint square)
   - Grid Survey Mission (3x3 mapping pattern)
   - Perimeter Inspection (boundary patrol)

## 🔒 Costa Rica Compliance

All sample missions use Costa Rica-compliant coordinates and altitudes:
- **Base Location**: 10.323520, -84.430511
- **Max Altitude**: 120m (below 150m legal limit)
- **Geofenced Operations**: Within 500m radius
- **Safety Requirements**: Min 20% battery, GPS level 3+

## 📝 Editing Missions Manually

You can edit mission files directly:

1. **Open Files app** → DroneAuto → DroneAutoMissions
2. **Tap and hold** a .json file → "Share" → "Copy to [JSON Editor]"
3. **Edit coordinates, altitudes, actions** as needed
4. **Save back** to the DroneAutoMissions folder
5. **Load in app** using "Load from Files"

## 🛡️ Validation

The app automatically validates:
- ✅ GPS coordinates within valid ranges
- ✅ Altitudes within safety limits
- ✅ Battery and GPS signal requirements
- ✅ Geofence boundaries
- ✅ JSON format correctness

Invalid missions will show clear error messages when loaded.

## 🔄 Version Control Tips

For advanced users managing multiple missions:

```bash
# Keep missions in version control
git add DroneAutoMissions/*.json
git commit -m "Add new survey missions for Site A"

# Share missions via GitHub
git push origin mission-plans

# Backup to cloud storage
# Files app syncs automatically with iCloud
```

## 🎯 Best Practices

1. **Test in Simulator First**: Create small test missions before complex ones
2. **Use Descriptive Names**: Include date, location, and purpose
3. **Tag Appropriately**: Use consistent tags for easy searching
4. **Keep Safety Margins**: Always stay well within legal limits
5. **Backup Regularly**: Files app automatically syncs to iCloud
6. **Document Changes**: Use version notes in descriptions

This JSON format provides complete flexibility while maintaining safety and simplicity for your drone automation projects!
