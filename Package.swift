// swift-tools-version: 5.8
import PackageDescription

// Note: This Package.swift is for reference only
// This project is designed as an iOS app, not a Swift Package
// To use this project:
// 1. Create a new iOS project in Xcode
// 2. Copy the DroneAutoApp/Source files to your project
// 3. Add the DJI Mobile SDK manually
// 4. Use the Info.plist configuration from DroneAutoApp/Configuration/

let package = Package(
    name: "DroneAutoApp-Reference",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "DroneAutoApp",
            targets: ["DroneAutoApp"]
        ),
    ],
    dependencies: [
        // DJI SDK needs to be added manually as it's not available via SPM
        // Download from: https://developer.dji.com/mobile-sdk/downloads/
    ],
    targets: [
        .target(
            name: "DroneAutoApp",
            dependencies: [],
            path: "DroneAutoApp/Source",
            exclude: [
                "../Configuration/Info.plist",
                "../Resources"
            ]
        ),
    ]
)
