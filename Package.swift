// swift-tools-version:6.0

import Foundation
import PackageDescription

extension String {
    static let identityProvider: Self = "Identity Provider"
    static let identityConsumer: Self = "Identity Consumer"
    static let identityShared: Self = "Identity Shared"
}

extension Target.Dependency {
    static var identityProvider: Self { .target(name: .identityProvider) }
    static var identityConsumer: Self { .target(name: .identityConsumer) }
    static var identityShared: Self { .target(name: .identityShared) }
}

extension Target.Dependency {
    static var coenttbAuthentication: Self { .product(name: "Coenttb Authentication", package: "coenttb-authentication") }
    static var coenttbWeb: Self { .product(name: "Coenttb Web", package: "coenttb-web") }
    static var dependenciesMacros: Self { .product(name: "DependenciesMacros", package: "swift-dependencies") }
    static var dependenciesTestSupport: Self { .product(name: "DependenciesTestSupport", package: "swift-dependencies") }
}

let package = Package(
    name: "swift-identity",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: .identityProvider, targets: [.identityProvider]),
        .library(name: .identityConsumer, targets: [.identityConsumer]),
        .library(name: .identityShared, targets: [.identityShared])
    ],
    dependencies: [
        .package(url: "https://github.com/coenttb/coenttb-web", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-authentication", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.6.3")
    ],
    targets: [
        .target(
            name: .identityShared,
            dependencies: [
                .coenttbWeb,
                .dependenciesMacros,
                .coenttbAuthentication
            ]
        ),
        .testTarget(
            name: .identityShared.tests,
            dependencies: [
                .identityShared,
                .dependenciesTestSupport
            ]
        ),
        .target(
            name: .identityConsumer,
            dependencies: [
                .coenttbWeb,
                .dependenciesMacros,
                .identityShared
            ]
        ),
        .testTarget(
            name: .identityConsumer.tests,
            dependencies: [
                .identityShared,
                .identityConsumer,
                .dependenciesTestSupport
            ]
        ),
        .target(
            name: .identityProvider,
            dependencies: [
                .identityShared,
                .coenttbWeb,
                .dependenciesMacros
            ]
        ),
        .testTarget(
            name: .identityProvider.tests,
            dependencies: [
                .identityShared,
                .identityProvider,
                .dependenciesTestSupport
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { "\(self) Tests" }
}
