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
    static var coenttbHtml: Self { .product(name: "CoenttbHTML", package: "coenttb-html") }
    static var coenttbMarkdown: Self { .product(name: "CoenttbMarkdown", package: "coenttb-html") }
    static var dependencies: Self { .product(name: "Dependencies", package: "swift-dependencies") }
    static var dependenciesMacros: Self { .product(name: "DependenciesMacros", package: "swift-dependencies") }
    static var dependenciesTestSupport: Self { .product(name: "DependenciesTestSupport", package: "swift-dependencies") }
    static var swiftDate: Self { .product(name: "Date", package: "swift-date") }
    static var language: Self { .product(name: "Languages", package: "swift-language") }
    static var logging: Self { .product(name: "Logging", package: "swift-log") }
    static var codable: Self { .product(name: "MacroCodableKit", package: "macro-codable-kit") }
    static var memberwiseInit: Self { .product(name: "MemberwiseInit", package: "swift-memberwise-init-macro") }
    static var environmentVariables: Self { .product(name: "EnvironmentVariables", package: "swift-environment-variables") }
    static var urlRouting: Self { .product(name: "URLRouting", package: "swift-url-routing") }
    static var either: Self { .product(name: "Either", package: "swift-prelude") }
    static var vapor: Self { .product(name: "Vapor", package: "Vapor") }
    static var coenttbVapor: Self { .product(name: "CoenttbVapor", package: "coenttb-web") }
    static var coenttbWebTranslations: Self { .product(name: "CoenttbWebTranslations", package: "coenttb-web") }
    static var coenttbWebHTML: Self { .product(name: "CoenttbWebHTML", package: "coenttb-web") }
    static var coenttbWebUtils: Self { .product(name: "CoenttbWebUtils", package: "coenttb-web") }
    static var coenttbEmail: Self { .product(name: "CoenttbEmail", package: "coenttb-html") }
    static var fluent: Self { .product(name: "Fluent", package: "fluent") }
    static var rateLimiter: Self { .product(name: "RateLimiter", package: "coenttb-utils") }
    static var urlFormCoding: Self { .product(name: "UrlFormCoding", package: "swift-web") }
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
        .package(url: "https://github.com/coenttb/coenttb-html", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-web", branch: "main"),
        .package(url: "https://github.com/coenttb/coenttb-utils", branch: "main"),
        .package(url: "https://github.com/coenttb/swift-date", branch: "main"),
        .package(url: "https://github.com/coenttb/swift-environment-variables.git", branch: "main"),
        .package(url: "https://github.com/coenttb/swift-language.git", branch: "main"),
        .package(url: "https://github.com/coenttb/swift-web", branch: "main"),
        .package(url: "https://github.com/coenttb/macro-codable-kit.git", branch: "main"),
        .package(url: "https://github.com/gohanlon/swift-memberwise-init-macro", from: "0.3.0"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.1.5"),
        .package(url: "https://github.com/pointfreeco/swift-url-routing", from: "0.6.0"),
        .package(url: "https://github.com/pointfreeco/swift-prelude", from: "0.6.0"),
        .package(url: "https://github.com/vapor/vapor.git", from: "4.102.1"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
    ],
    targets: [
        .target(
            name: .coenttbIdentity,
            dependencies: [
                .codable,
                .coenttbEmail,
                .coenttbHtml,
                .coenttbMarkdown,
                .coenttbWebTranslations,
                .coenttbWebUtils,
                .coenttbWebHTML,
                .dependencies,
                .dependenciesMacros,
                .either,
                .memberwiseInit,
                .language,
                .swiftDate,
                .urlRouting,
                .urlFormCoding,
            ]
        ),
        .target(
            name: .coenttbIdentityLive,
            dependencies: [
                .coenttbIdentity,
                .vapor,
                .dependencies,
                .coenttbWebUtils,
                .rateLimiter,
                .coenttbVapor,
            ]
        ),
        .target(
            name: .coenttbIdentityFluent,
            dependencies: [
                .coenttbIdentityLive,
                .coenttbIdentity,
                .fluent,
                .vapor,
                .dependencies,
                .coenttbWebUtils,
                .fluent,
                .rateLimiter,
                .coenttbVapor,
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
