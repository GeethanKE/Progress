// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Progress",
    platforms: [
        .macOS(.v12)
    ],
    targets: [
        .executableTarget(
            name: "Progress",
            path: "Sources/Progress"
        )
    ]
)
