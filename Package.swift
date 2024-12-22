// swift-tools-version:6.0

import Foundation
import PackageDescription

extension String {
    static let coenttbIdentity: Self = "CoenttbIdentity"
    static let coenttbIdentityLive: Self = "CoenttbIdentityLive"
    static let coenttbIdentityFluent: Self = "CoenttbIdentityFluent"
}

extension Target.Dependency {
    static var coenttbIdentity: Self { .target(name: .coenttbIdentity) }
    static var coenttbIdentityLive: Self { .target(name: .coenttbIdentityLive) }
    static var coenttbIdentityFluent: Self { .target(name: .coenttbIdentityFluent) }
}

extension Target.Dependency {
    static var coenttbWeb: Self { .product(name: "CoenttbWeb", package: "coenttb-web") }
    static var codable: Self { .product(name: "MacroCodableKit", package: "macro-codable-kit") }
    static var dependenciesMacros: Self { .product(name: "DependenciesMacros", package: "swift-dependencies") }
    static var dependenciesTestSupport: Self { .product(name: "DependenciesTestSupport", package: "swift-dependencies") }
    static var memberwiseInit: Self { .product(name: "MemberwiseInit", package: "swift-memberwise-init-macro") }
    static var mailgun: Self { .product(name: "Mailgun", package: "coenttb-mailgun") }
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
        .package(url: "https://github.com/coenttb/coenttb-mailgun", branch: "main"),
        .package(url: "https://github.com/coenttb/macro-codable-kit.git", branch: "main"),
        .package(url: "https://github.com/gohanlon/swift-memberwise-init-macro", from: "0.3.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.6.0"),
    ],
    targets: [
        .target(
            name: .coenttbIdentity,
            dependencies: [
                .coenttbWeb,
                .codable,
                .dependenciesMacros,
                .memberwiseInit,
            ]
        ),
        .target(
            name: .coenttbIdentityLive,
            dependencies: [
                .coenttbWeb,
                .coenttbIdentity,
                .mailgun
            ]
        ),
        .target(
            name: .coenttbIdentityFluent,
            dependencies: [
                .coenttbWeb,
                .coenttbIdentity,
                .coenttbIdentityLive,
            ]
        ),
        .testTarget(
            name: .coenttbIdentity + " Tests",
            dependencies: [
                .coenttbIdentity,
                .dependenciesTestSupport
            ]
        )
    ],
    swiftLanguageModes: [.v6]
)
