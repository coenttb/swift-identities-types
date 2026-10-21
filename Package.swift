// swift-tools-version: 6.4

import Foundation
import PackageDescription

extension String {
    static let identitiesTypes: Self = "IdentitiesTypes"
}

extension Target.Dependency {
    static var identitiesTypes: Self { .target(name: .identitiesTypes) }
}

extension Target.Dependency {
    static var jwt: Self { .product(name: "JWT", package: "swift-json-web-token") }
    static var emailAddress: Self { .product(name: "EmailAddress", package: "swift-emailaddress") }
    static var caseMacro: Self { .product(name: "Case Macro", package: "swift-optic") }
    static var rfc6750: Self { .product(name: "RFC 6750", package: "swift-rfc-6750") }
    static var httpRouter: Self { .product(name: "HTTP Router", package: "swift-http-router") }
    static var coder: Self { .product(name: "Coder", package: "swift-coder") }
    static var htmlFormCoder: Self {
        .product(name: "HTML Form Coder Codable", package: "swift-html-form-coder")
    }
    static var htmlStandard: Self {
        .product(name: "HTML Standard", package: "swift-html-standard")
    }
    static var dependencies: Self { .product(name: "Dependencies", package: "swift-dependencies") }
    static var dependenciesTestSupport: Self {
        .product(name: "Dependencies Test Support", package: "swift-dependencies")
    }
    static var tagged: Self { .product(name: "Tagged", package: "swift-tagged") }
}

let package = Package(
    name: "swift-identities-types",
    platforms: [
        // Bumped from macOS(.v14)/iOS(.v17): the swift-compositions/swift-json-web-token
        // dependency's own Package.swift declares macOS(.v26)/iOS(.v26) as its minimum —
        // SwiftPM propagates a dependency's platform floor upward to consumers.
        .macOS("27"),
        .iOS("27"),
    ],
    products: [
        .library(name: .identitiesTypes, targets: [.identitiesTypes])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-compositions/swift-dependencies.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-emailaddress.git", branch: "main"),
        .package(url: "https://github.com/swift-standards/swift-emailaddress-standard.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-json-web-token.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-tagged.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-html-form-coder.git", branch: "main"),
        .package(url: "https://github.com/swift-standards/swift-html-standard.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-optic.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-6750.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-http-router.git", branch: "main", traits: ["Foundation"]),
        .package(url: "https://github.com/swift-atoms/swift-pair.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-coder.git", branch: "main", traits: ["Checkpoint", "Optic", "Skip", "Byte", "Operation", "Map", "Pair"]),
    ],
    targets: [
        .target(
            name: .identitiesTypes,
            dependencies: [
                .dependencies,
                .emailAddress,
                .product(name: "EmailAddress Foundation Integration", package: "swift-emailaddress-standard"),
                .jwt,
                .caseMacro,
                .rfc6750,
                .httpRouter,
                .coder,
                .product(name: "Pair", package: "swift-pair"),
                .htmlFormCoder,
                .htmlStandard,
                .tagged,
            ]
        ),
        .testTarget(
            name: .identitiesTypes.tests,
            dependencies: [
                .identitiesTypes,
                .dependenciesTestSupport,
            ]
        ),
        .testTarget(
            name: "Identities Router Parity Tests",
            dependencies: [
                .identitiesTypes,
                .httpRouter,
            ],
            path: "Tests/Identities Router Parity Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String { var tests: Self { "\(self) Tests" } }
