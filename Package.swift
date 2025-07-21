// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "DroneAutoApp",
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
            path: "Source"
        ),
    ]
)
