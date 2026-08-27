// swift-tools-version: 6.3.3

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
    static var dual: Self { .product(name: "Dual", package: "swift-dual") }
    static var rfc6750: Self { .product(name: "RFC 6750", package: "swift-rfc-6750") }
    static var urlRouting: Self { .product(name: "URLRouting", package: "swift-url-routing") }
    static var urlRoutingFoundationIntegration: Self { .product(name: "URL Routing Foundation Integration", package: "swift-url-routing") }
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
        .iOS("27")
    ],
    products: [
        .library(name: .identitiesTypes, targets: [.identitiesTypes])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-compositions/swift-dependencies.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-emailaddress.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-json-web-token.git", branch: "main"),
        .package(url: "https://github.com/swift-molecules/swift-tagged.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-html-form-coder.git", branch: "main"),
        .package(url: "https://github.com/swift-standards/swift-html-standard.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-dual.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-6750.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-url-routing.git", branch: "main"),
    ],
    targets: [
        .target(
            name: .identitiesTypes,
            dependencies: [
                .dependencies,
                .emailAddress,
                .jwt,
                .dual,
                .rfc6750,
                .urlRouting,
                .urlRoutingFoundationIntegration,
                .htmlFormCoder,
                .htmlStandard,
                .tagged
            ]
        ),
        .testTarget(
            name: .identitiesTypes.tests,
            dependencies: [
                .identitiesTypes,
                .dependenciesTestSupport
            ]
        ),
        .testTarget(
            name: "Identities Router Parity Tests",
            dependencies: [
                .identitiesTypes,
                .product(name: "URL Routing Test Support", package: "swift-url-routing")
            ],
            path: "Tests/Identities Router Parity Tests"
        )
    ],
    swiftLanguageModes: [.v6]
)

extension String { var tests: Self { "\(self) Tests" } }
