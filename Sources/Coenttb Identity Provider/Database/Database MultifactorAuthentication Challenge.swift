//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Coenttb_Identity_Shared
import Dependencies
@preconcurrency import Fluent
import Foundation
@preconcurrency import Vapor

extension Database.MultifactorAuthentication {
    package final class Challenge: Model, Content, @unchecked Sendable {
        package static let schema = "mfa_challenges"

        @ID(key: .id)
        package var id: UUID?

        @Parent(key: FieldKeys.identityId)
        package var identity: Database.Identity

        @Enum(key: FieldKeys.type)
        package var type: Identity.Authentication.Multifactor.Method

        @Field(key: FieldKeys.code)
        package var code: String

        @Field(key: FieldKeys.attempts)
        package var attempts: Int

        @Timestamp(key: FieldKeys.createdAt, on: .create)
        package var createdAt: Date?

        @Field(key: FieldKeys.expiresAt)
        package var expiresAt: Date

        package enum FieldKeys {
            package static let identityId: FieldKey = "identity_id"
            package static let type: FieldKey = "type"
            package static let code: FieldKey = "code"
            package static let attempts: FieldKey = "attempts"
            package static let createdAt: FieldKey = "created_at"
            package static let expiresAt: FieldKey = "expires_at"
        }

        package init() {}

        package init(
            id: UUID? = nil,
            identity: Database.Identity,
            type: Identity.Authentication.Multifactor.Method,
            code: String,
            attempts: Int = 0,
            expiresAt: Date = Date().addingTimeInterval(300)
        ) throws {
            self.id = id
            self.$identity.id = try identity.requireID()
            self.type = type
            self.code = code
            self.attempts = attempts
            self.expiresAt = expiresAt
        }
    }
}

extension Database.MultifactorAuthentication.Challenge {
    package enum Migration {
        package struct Create: AsyncMigration {
            package var name: String = "Identity_Provider.MultifactorAuthentication.Challenge.Migration.Create"

            package init() {}

            package func prepare(on database: Fluent.Database) async throws {
                try await database.schema(Database.MultifactorAuthentication.Challenge.schema)
                    .id()
                    .field(FieldKeys.identityId, .uuid, .required, .references(Database.Identity.schema, "id", onDelete: .cascade))
                    .field(FieldKeys.type, .string, .required)
                    .field(FieldKeys.code, .string, .required)
                    .field(FieldKeys.attempts, .int, .required)
                    .field(FieldKeys.createdAt, .datetime)
                    .field(FieldKeys.expiresAt, .datetime, .required)
                    .create()
            }

            package func revert(on database: Fluent.Database) async throws {
                try await database.schema(Database.MultifactorAuthentication.Challenge.schema).delete()
            }
        }
    }
}
