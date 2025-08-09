// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CapacitorPluginVideo",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "CapacitorPluginVideo",
            targets: ["VideoPlugin"])
    ],
    dependencies: [
        .package(url: "https://github.com/ionic-team/capacitor-swift-pm.git", from: "7.0.0")
    ],
    targets: [
        // ObjC shim target exposing Capacitor macros
        .target(
            name: "VideoPluginObjC",
            dependencies: [
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/VideoPluginObjC",
            publicHeadersPath: "include"),
        // Swift implementation target depends on ObjC shim
        .target(
            name: "VideoPlugin",
            dependencies: [
                "VideoPluginObjC",
                .product(name: "Capacitor", package: "capacitor-swift-pm"),
                .product(name: "Cordova", package: "capacitor-swift-pm")
            ],
            path: "ios/Sources/VideoPlugin"),
        .testTarget(
            name: "VideoPluginTests",
            dependencies: ["VideoPlugin"],
            path: "ios/Tests/VideoPluginTests")
    ]
)