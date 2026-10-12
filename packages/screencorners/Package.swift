// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "ScreenCorners",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .library(name: "ScreenCornersCore", targets: ["ScreenCornersCore"]),
    .executable(name: "ScreenCorners", targets: ["ScreenCorners"]),
  ],
  targets: [
    .target(name: "ScreenCornersCore"),
    .executableTarget(
      name: "ScreenCorners",
      dependencies: ["ScreenCornersCore"]
    ),
    .testTarget(
      name: "ScreenCornersCoreTests",
      dependencies: ["ScreenCornersCore"]
    ),
  ]
)
