// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "simple-spreadsheets",
    platforms: [
        .macOS(.v10_11),
        .iOS(.v9),
        .tvOS(.v9),
        .watchOS(.v2),
    ],
    products: [
        .library(
            name: "SimpleSpreadsheets",
            targets: ["SimpleSpreadsheets"]),
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.12"),
    ],
    targets: [
        .target(
            name: "SimpleSpreadsheets",
            dependencies: ["ZIPFoundation"]),
        .testTarget(
            name: "SimpleSpreadsheetsTests",
            dependencies: ["SimpleSpreadsheets"]),
    ]
)
