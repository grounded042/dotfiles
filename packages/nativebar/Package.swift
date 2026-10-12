// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "NativeBar",
  platforms: [
    .macOS(.v14)
  ],
  products: [
    .library(name: "NativeBarCore", targets: ["NativeBarCore"]),
    .executable(name: "NativeBar", targets: ["NativeBar"]),
  ],
  targets: [
    .target(name: "NativeBarCore"),
    .executableTarget(
      name: "NativeBar",
      dependencies: ["NativeBarCore"],
      linkerSettings: [
        .linkedFramework("AudioToolbox"),
        .linkedFramework("CoreAudio"),
        .linkedFramework("CoreLocation"),
        .linkedFramework("CoreWLAN"),
        .linkedFramework("IOKit"),
        .linkedFramework("Network"),
      ]
    ),
    .testTarget(
      name: "NativeBarCoreTests",
      dependencies: ["NativeBarCore"]
    ),
  ]
)
