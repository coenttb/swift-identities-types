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
import Coenttb_Identity_Shared

extension Database.MultifactorAuthentication {
    public final class Challenge: Model, Content, @unchecked Sendable {
        public static let schema = "mfa_challenges"

        @ID(key: .id)
        public var id: UUID?

        @Parent(key: FieldKeys.identityId)
        public var identity: Database.Identity

        @Enum(key: FieldKeys.type)
        public var type: Identity.Authentication.Multifactor.Method

        @Field(key: FieldKeys.code)
        public var code: String

        @Field(key: FieldKeys.attempts)
        public var attempts: Int

        @Timestamp(key: FieldKeys.createdAt, on: .create)
        public var createdAt: Date?

        @Field(key: FieldKeys.expiresAt)
        public var expiresAt: Date

        package enum FieldKeys {
            public static let identityId: FieldKey = "identity_id"
            public static let type: FieldKey = "type"
            public static let code: FieldKey = "code"
            public static let attempts: FieldKey = "attempts"
            public static let createdAt: FieldKey = "created_at"
            public static let expiresAt: FieldKey = "expires_at"
        }

        public init() {}

        public init(
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
    public enum Migration {
        public struct Create: AsyncMigration {
            public var name: String = "Identity_Provider.MultifactorAuthentication.Challenge.Migration.Create"
            
            public init() {}

            public func prepare(on database: Fluent.Database) async throws {
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

            public func revert(on database: Fluent.Database) async throws {
                try await database.schema(Database.MultifactorAuthentication.Challenge.schema).delete()
            }
        }
    }
}
