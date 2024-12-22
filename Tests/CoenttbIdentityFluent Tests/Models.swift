//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 22/12/2024.
//

import Foundation
import CoenttbWeb
import CoenttbIdentityFluent

// Test Models
struct TestUser: Codable, Equatable {
    let id: UUID
    let email: String
}

final class TestDatabaseUser: Model, @unchecked Sendable {
    static let schema = "test_users"
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: "identity_id")
    var identity: Identity
    
    init() { }
}

extension TestDatabaseUser {
    struct Migration: AsyncMigration {
        func prepare(on database: Database) async throws {
            try await database.schema(TestDatabaseUser.schema)
                .id()
                .field("identity_id", .uuid, .required, .references(Identity.schema, "id", onDelete: .cascade))
                .unique(on: "identity_id") // Ensure one-to-one relationship
                .create()
        }
        
        func revert(on database: Database) async throws {
            try await database.schema(TestDatabaseUser.schema).delete()
        }
    }
}
