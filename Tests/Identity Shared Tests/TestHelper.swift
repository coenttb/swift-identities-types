//
//  File.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 20/02/2025.
//

import Foundation
import Identity_Shared
import Dependencies

struct TestHelper {
    static let enabled: Bool = true
    /// Creates an isolated test environment for each test
    static func withIsolatedDatabase(_ operation: @escaping () async throws -> Void) async throws {
        if enabled {
            let database = Identity.Client.TestDatabase()
            try await withDependencies {
                $0[Identity.Client.TestDatabase.self] = database
                $0[Identity.Client.self] = .testValue
            } operation: {
                try await operation()
            }
        } else {
            try await operation()
        }
    }
}
