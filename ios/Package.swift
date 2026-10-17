// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "JarvisApp",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "JarvisCore", targets: ["JarvisCore"])
    ],
    targets: [
        .target(
            name: "JarvisCore",
            path: "JarvisCore/Sources/JarvisCore"
        ),
        .testTarget(
            name: "JarvisTests",
            dependencies: ["JarvisCore"],
            path: "JarvisTests"
        )
    ]
)
