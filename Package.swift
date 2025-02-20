// swift-tools-version:6.0

import Foundation
import PackageDescription

extension String {
    static let identities: Self = "Identities"
    static let identityProvider: Self = "IdentityProvider"
    static let identityConsumer: Self = "IdentityConsumer"
    static let identityShared: Self = "IdentityShared"
}

extension Target.Dependency {
    static var identityProvider: Self { .target(name: .identityProvider) }
    static var identityConsumer: Self { .target(name: .identityConsumer) }
    static var identityShared: Self { .target(name: .identityShared) }
}

extension Target.Dependency {
    static var coenttbAuthentication: Self { .product(name: "Coenttb Authentication", package: "coenttb-authentication") }
    static var swiftWeb: Self { .product(name: "SwiftWeb", package: "swift-web") }
    static var dependenciesMacros: Self { .product(name: "DependenciesMacros", package: "swift-dependencies") }
    static var dependenciesTestSupport: Self { .product(name: "DependenciesTestSupport", package: "swift-dependencies") }
}

let package = Package(
    name: "swift-identities",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: .identityProvider, targets: [.identityProvider]),
        .library(name: .identityConsumer, targets: [.identityConsumer]),
    ],
    dependencies: [
        .package(url: "https://github.com/coenttb/coenttb-authentication", branch: "main"),
        .package(url: "https://github.com/coenttb/swift-web", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.6.3")
    ],
    targets: [
        .target(
            name: .identities,
            dependencies: [
                .identityProvider,
                .identityConsumer,
                .identityShared,
            ]
        ),
        .target(
            name: .identityShared,
            dependencies: [
                .swiftWeb,
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
                .swiftWeb,
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
                .swiftWeb,
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

#if !os(Windows)
  // Add the documentation compiler plugin if possible
  package.dependencies.append(
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.4.0")
  )
#endif
