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
        package static func withIsolatedDatabase(_ operation: @escaping () async throws -> Void) async throws {
            if enabled {
                let database = Identity._TestDatabase()
                try await withDependencies {
                    $0[Identity._TestDatabase.self] = database
                    $0[Identity.self] = .testValue
                } operation: {
                    try await operation()
                }
            } else {
                try await operation()
            }
        }
    }
}

