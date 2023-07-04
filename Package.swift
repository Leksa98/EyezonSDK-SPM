// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EyezonSDK",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "EyezonSDK",
            targets: ["EyezonSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios.git", exact: "4.2.0"),
		.package(url: "https://github.com/mchoe/SwiftSVG.git", exact: "2.3.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "EyezonSDK",
			dependencies: [
				.product(name: "Lottie", package: "lottie-ios"),
				.product(name: "SwiftSVG", package: "SwiftSVG"),
			])
    ]
)
