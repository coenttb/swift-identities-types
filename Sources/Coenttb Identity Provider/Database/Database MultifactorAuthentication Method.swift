//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Dependencies
@preconcurrency import Fluent
import Foundation
@preconcurrency import Vapor
import Identity_Shared
import Coenttb_Identity_Shared

extension Database.MultifactorAuthentication {
    package final class Method: Model, Content, @unchecked Sendable {
        package static let schema = "mfa_methods"

        @ID(key: .id)
        package var id: UUID?

        @Parent(key: FieldKeys.identityId)
        package var identity: Database.Identity

        @Enum(key: FieldKeys.type)
        package var type: Identity.Authentication.Multifactor.Method

        @Field(key: FieldKeys.identifier)
        package var identifier: String

        @Field(key: FieldKeys.verified)
        package var verified: Bool

        @Timestamp(key: FieldKeys.createdAt, on: .create)
        package var createdAt: Date?

        @OptionalField(key: FieldKeys.lastUsedAt)
        package var lastUsedAt: Date?

        package enum FieldKeys {
            package static let identityId: FieldKey = "identity_id"
            package static let type: FieldKey = "type"
            package static let identifier: FieldKey = "identifier"
            package static let verified: FieldKey = "verified"
            package static let createdAt: FieldKey = "created_at"
            package static let lastUsedAt: FieldKey = "last_used_at"
        }

        package init() {}

        package init(
            id: UUID? = nil,
            identity: Database.Identity,
            type: Identity.Authentication.Multifactor.Method,
            identifier: String,
            verified: Bool = false
        ) throws {
            self.id = id
            self.$identity.id = try identity.requireID()
            self.type = type
            self.identifier = identifier
            self.verified = verified
        }
    }
}


extension Database.MultifactorAuthentication.Method {
    package enum Migration {
        package struct Create: AsyncMigration {
            package var name: String = "Identity_Provider.MultifactorAuthentication.Method.Migration.Create"
            
            package init() {}

            package func prepare(on database: Fluent.Database) async throws {
                try await database.schema(Database.MultifactorAuthentication.Method.schema)
                    .id()
                    .field(FieldKeys.identityId, .uuid, .required, .references(Database.Identity.schema, "id", onDelete: .cascade))
                    .field(FieldKeys.type, .string, .required)
                    .field(FieldKeys.identifier, .string, .required)
                    .field(FieldKeys.verified, .bool, .required)
                    .field(FieldKeys.createdAt, .datetime)
                    .field(FieldKeys.lastUsedAt, .datetime)
                    .unique(on: FieldKeys.identityId, FieldKeys.type)
                    .create()
            }

            package func revert(on database: Fluent.Database) async throws {
                try await database.schema(Database.MultifactorAuthentication.Method.schema).delete()
            }
        }
    }
}
