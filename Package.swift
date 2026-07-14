// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DiyaninHomeDioramaScene",
    platforms: [
        .iOS(.v18),
        .visionOS(.v2)
    ],
    products: [
        .library(name: "DiyaninHomeDioramaScene", targets: ["DiyaninHomeDioramaScene"])
    ],
    targets: [
        .target(name: "DiyaninHomeDioramaScene")
    ]
)
