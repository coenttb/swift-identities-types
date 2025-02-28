// swift-tools-version:6.0

import Foundation
import PackageDescription

extension String {
    static let coenttbIdentityProvider: Self = "Coenttb Identity Provider"
    static let coenttbIdentityConsumer: Self = "Coenttb Identity Consumer"
    static let coenttbIdentityShared: Self = "Coenttb Identity Shared"
}

extension Target.Dependency {
    static var coenttbIdentityProvider: Self { .target(name: .coenttbIdentityProvider) }
    static var coenttbIdentityConsumer: Self { .target(name: .coenttbIdentityConsumer) }
    static var coenttbIdentityShared: Self { .target(name: .coenttbIdentityShared) }
}

extension Target.Dependency {
    static var coenttbWeb: Self { .product(name: "Coenttb Web", package: "coenttb-web") }
    static var coenttbServer: Self { .product(name: "Coenttb Server", package: "coenttb-server") }
    static var coenttbVapor: Self { .product(name: "Coenttb Vapor", package: "coenttb-server-vapor") }
    static var coenttbFluent: Self { .product(name: "Coenttb Fluent", package: "coenttb-server-vapor") }
    static var identities: Self { .product(name: "Identities", package: "swift-identities") }
    static var dependenciesMacros: Self { .product(name: "DependenciesMacros", package: "swift-dependencies") }
    static var dependenciesTestSupport: Self { .product(name: "DependenciesTestSupport", package: "swift-dependencies") }
    static var mailgun: Self { .product(name: "Mailgun", package: "coenttb-mailgun") }
    static var fluentSqlLite: Self { .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver") }
    static var vaporJWT: Self { .product(name: "JWT", package: "jwt") }
    static var vaporTesting: Self { .product(name: "VaporTesting", package: "vapor") }
}

let package = Package(
    name: "coenttb-identities",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: .coenttbIdentityProvider, targets: [.coenttbIdentityProvider]),
        .library(name: .coenttbIdentityConsumer, targets: [.coenttbIdentityConsumer])
    ],
    dependencies: [
        .package(url: "https://github.com/coenttb/coenttb-web", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-server", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-server-vapor", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-mailgun", branch: "main"),
        .package(url: "https://github.com/coenttb/swift-identities", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.6.3"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "5.0.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.113.2")
    ],
    targets: [
        .target(
            name: .coenttbIdentityShared,
            dependencies: [
                .identities,
                .coenttbWeb,
                .dependenciesMacros,
                .vaporJWT,
                .coenttbVapor
            ]
        ),
        .target(
            name: .coenttbIdentityConsumer,
            dependencies: [
                .identities,
                .coenttbWeb,
                .dependenciesMacros,
                .coenttbIdentityShared,
                .coenttbVapor,
                .vaporJWT   
            ]
        ),
        .target(
            name: .coenttbIdentityProvider,
            dependencies: [
                .identities,
                .coenttbWeb,
                .coenttbServer,
                .coenttbVapor,
                .coenttbFluent,
                .coenttbIdentityShared,
                .mailgun

            ]
        ),
        .testTarget(
            name: .coenttbIdentityConsumer.tests,
            dependencies: [
                .coenttbIdentityConsumer,
                .coenttbIdentityProvider,
                .dependenciesTestSupport,
                .vaporTesting,
            ]
        ),
        .testTarget(
            name: .coenttbIdentityProvider.tests,
            dependencies: [
                .coenttbIdentityProvider,
                .dependenciesTestSupport,
                .fluentSqlLite,
                .vaporTesting,
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { "\(self) Tests" }
}
