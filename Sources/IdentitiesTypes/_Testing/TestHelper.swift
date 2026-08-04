//
//  File.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 20/02/2025.
//

import Dependencies
import Foundation

extension Identity._TestDatabase {
    package struct Helper {
        package static let enabled: Bool = true
        /// Creates an isolated test environment for each test
        package static func withIsolatedDatabase<Failure: Swift.Error>(
            _ operation: @escaping () async throws(Failure) -> Void
        ) async throws(Failure) {
            if enabled {
                let database = Identity._TestDatabase()
                try await withDependencies {
                    $0[Identity._TestDatabase.self] = database
                    $0[Identity.self] = .testValue
                } operation: { () async throws(Failure) -> Void in
                    try await operation()
                }
            } else {
                try await operation()
            }
        }
    }
}
