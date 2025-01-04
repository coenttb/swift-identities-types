// swift-tools-version:6.0

import Foundation
import PackageDescription

extension String {
    static let coenttbIdentity: Self = "Coenttb Identity"
    static let coenttbIdentityLive: Self = "Coenttb Identity Live"
    static let coenttbIdentityFluent: Self = "Coenttb Identity Fluent"
}

extension Target.Dependency {
    static var coenttbIdentity: Self { .target(name: .coenttbIdentity) }
    static var coenttbIdentityLive: Self { .target(name: .coenttbIdentityLive) }
    static var coenttbIdentityFluent: Self { .target(name: .coenttbIdentityFluent) }
}

extension Target.Dependency {
    static var coenttbWeb: Self { .product(name: "Coenttb Web", package: "coenttb-web") }
    static var coenttbServer: Self { .product(name: "Coenttb Server", package: "coenttb-server") }
    static var coenttbServerVapor: Self { .product(name: "Coenttb Vapor", package: "coenttb-server-vapor") }
    static var coenttbServerFluent: Self { .product(name: "Coenttb Fluent", package: "coenttb-server-vapor") }
    static var dependenciesMacros: Self { .product(name: "DependenciesMacros", package: "swift-dependencies") }
    static var dependenciesTestSupport: Self { .product(name: "DependenciesTestSupport", package: "swift-dependencies") }
    static var mailgun: Self { .product(name: "Mailgun", package: "coenttb-mailgun") }
    static var fluentSqlLite: Self { .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver") }
}

let package = Package(
    name: "coenttb-identity",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: .coenttbIdentity, targets: [.coenttbIdentity]),
        .library(name: .coenttbIdentityLive, targets: [.coenttbIdentityLive]),
        .library(name: .coenttbIdentityFluent, targets: [.coenttbIdentityFluent]),
    ],
    dependencies: [
        .package(url: "https://github.com/coenttb/coenttb-web", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-server", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-server-vapor", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-mailgun", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.6.3"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: .coenttbIdentity,
            dependencies: [
                .coenttbWeb,
                .dependenciesMacros,
            ]
        ),
        .target(
            name: .coenttbIdentityLive,
            dependencies: [
                .coenttbWeb,
                .coenttbServer,
                .coenttbIdentity,
                .mailgun
            ]
        ),
        .target(
            name: .coenttbIdentityFluent,
            dependencies: [
                .coenttbWeb,
                .coenttbServer,
                .coenttbIdentity,
                .coenttbIdentityLive,
                .coenttbServerVapor,
                .coenttbServerFluent,
            ]
        ),
        .testTarget(
            name: .coenttbIdentity + " Tests",
            dependencies: [
                .coenttbIdentity,
                .dependenciesTestSupport
            ]
        ),
        .testTarget(
            name: .coenttbIdentityLive + " Tests",
            dependencies: [
                .coenttbIdentityLive,
                .dependenciesTestSupport,
                .fluentSqlLite,
                .mailgun
            ]
        ),
        .testTarget(
            name: .coenttbIdentityFluent + " Tests",
            dependencies: [
                .coenttbIdentityFluent,
                .dependenciesTestSupport,
                .fluentSqlLite
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
