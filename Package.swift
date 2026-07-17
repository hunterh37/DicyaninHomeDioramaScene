// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DicyaninHomeDioramaScene",
    platforms: [
        .iOS(.v18),
        .visionOS(.v2)
    ],
    products: [
        .library(name: "DicyaninHomeDioramaScene", targets: ["DicyaninHomeDioramaScene"])
    ],
    targets: [
        .target(name: "DicyaninHomeDioramaScene")
    ]
)
