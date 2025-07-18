// swift-tools-version:6.0

import Foundation
import PackageDescription

extension String {
    static let identities: Self = "Identities"
}

extension Target.Dependency {
    static var identities: Self { .target(name: .identities) }
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
        .library(name: .identities, targets: [.identities])
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
                .swiftWeb,
                .dependenciesMacros,
                .coenttbAuthentication
            ]
        ),
        .testTarget(
            name: .identities.tests,
            dependencies: [
                .identities,
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
