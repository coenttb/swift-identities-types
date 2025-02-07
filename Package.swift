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
    static var coenttbServerVapor: Self { .product(name: "Coenttb Vapor", package: "coenttb-server-vapor") }
    static var coenttbServerFluent: Self { .product(name: "Coenttb Fluent", package: "coenttb-server-vapor") }
    static var identityConsumer: Self { .product(name: "Identity Consumer", package: "swift-identity") }
    static var identityProvider: Self { .product(name: "Identity Provider", package: "swift-identity") }
    static var identityShared: Self { .product(name: "Identity Shared", package: "swift-identity") }
    static var dependenciesMacros: Self { .product(name: "DependenciesMacros", package: "swift-dependencies") }
    static var dependenciesTestSupport: Self { .product(name: "DependenciesTestSupport", package: "swift-dependencies") }
    static var mailgun: Self { .product(name: "Mailgun", package: "coenttb-mailgun") }
    static var fluentSqlLite: Self { .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver") }
    static var vaporJWT: Self { .product(name: "JWT", package: "jwt") }
}

let package = Package(
    name: "coenttb-identity",
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
        .package(url: "https://github.com/coenttb/swift-identity", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.6.3"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: .coenttbIdentityShared,
            dependencies: [
                .identityShared,
                .coenttbWeb,
                .dependenciesMacros,
                .vaporJWT,
            ]
        ),
        .target(
            name: .coenttbIdentityConsumer,
            dependencies: [
                .identityConsumer,
                .coenttbWeb,
                .dependenciesMacros,
                .coenttbIdentityShared,
                .coenttbServerVapor,
                .vaporJWT,
            ]
        ),
        .target(
            name: .coenttbIdentityProvider,
            dependencies: [
                .identityProvider,
                .coenttbWeb,
                .coenttbServer,
                .coenttbServerVapor,
                .coenttbServerFluent,
                .coenttbIdentityShared,
                .mailgun,

            ]
        ),
        .testTarget(
            name: .coenttbIdentityProvider.tests,
            dependencies: [
                .coenttbIdentityProvider,
                .dependenciesTestSupport,
                .fluentSqlLite
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { "\(self) Tests" }
}
