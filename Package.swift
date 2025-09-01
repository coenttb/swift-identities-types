// swift-tools-version:6.0

import Foundation
import PackageDescription

extension String {
    static let identitiesTypes: Self = "IdentitiesTypes"
}

extension Target.Dependency {
    static var identitiesTypes: Self { .target(name: .identitiesTypes) }
}

extension Target.Dependency {
    static var authentication: Self { .product(name: "Authenticating", package: "swift-authenticating") }
    static var serverFoundation: Self { .product(name: "ServerFoundation", package: "swift-server-foundation") }
    static var dependenciesMacros: Self { .product(name: "DependenciesMacros", package: "swift-dependencies") }
    static var dependenciesTestSupport: Self { .product(name: "DependenciesTestSupport", package: "swift-dependencies") }
}

let package = Package(
    name: "swift-identities-types",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: .identitiesTypes, targets: [.identitiesTypes])
    ],
    dependencies: [
        .package(url: "https://github.com/coenttb/swift-authenticating", from: "0.0.1"),
        .package(url: "https://github.com/coenttb/swift-types-foundation", from: "0.0.1"),
        .package(url: "https://github.com/coenttb/swift-server-foundation", from: "0.0.1"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.9.2")
    ],
    targets: [
        .target(
            name: .identitiesTypes,
            dependencies: [
                .serverFoundation,
                .dependenciesMacros,
                .authentication
            ]
        ),
        .testTarget(
            name: .identitiesTypes.tests,
            dependencies: [
                .identitiesTypes,
                .dependenciesTestSupport
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

extension String { var tests: Self { "\(self) Tests" } }
