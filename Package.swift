// swift-tools-version: 5.8
// This Package.swift is for reference only - this is an iOS app project
// 
// To use this project:
// 1. Create a new iOS app project in Xcode
// 2. Copy DroneAutoApp/Source/ files to your Xcode project
// 3. Add DroneAutoApp/Configuration/Info.plist settings
// 4. Download DJI Mobile SDK and add to project
// 5. Configure your DJI app key in AppDelegate.swift

import PackageDescription

let package = Package(
    name: "DroneAutoApp",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "DroneAutoApp", targets: ["DroneAutoApp"])
    ],
    targets: [
        .target(
            name: "DroneAutoApp",
            path: "DroneAutoApp/Source",
            exclude: ["../Configuration", "../Resources"]
        )
    ]
)
