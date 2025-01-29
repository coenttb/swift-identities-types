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

extension MultifactorAuthentication {
    public final class Method: Model, Content, @unchecked Sendable {
        public static let schema = "mfa_methods"

        @ID(key: .id)
        public var id: UUID?

        @Parent(key: FieldKeys.identityId)
        public var identity: Identity

        @Enum(key: FieldKeys.type)
        public var type: Identity_Shared.MultifactorAuthentication.Method

        @Field(key: FieldKeys.identifier)
        public var identifier: String

        @Field(key: FieldKeys.verified)
        public var verified: Bool

        @Timestamp(key: FieldKeys.createdAt, on: .create)
        public var createdAt: Date?

        @OptionalField(key: FieldKeys.lastUsedAt)
        public var lastUsedAt: Date?

        public enum FieldKeys {
            public static let identityId: FieldKey = "identity_id"
            public static let type: FieldKey = "type"
            public static let identifier: FieldKey = "identifier"
            public static let verified: FieldKey = "verified"
            public static let createdAt: FieldKey = "created_at"
            public static let lastUsedAt: FieldKey = "last_used_at"
        }

        public init() {}

        public init(
            id: UUID? = nil,
            identity: Identity,
            type: Identity_Shared.MultifactorAuthentication.Method,
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


extension Coenttb_Identity_Provider.MultifactorAuthentication.Method {
    public enum Migration {
        public struct Create: AsyncMigration {
            public var name: String = "Identity_Provider.MultifactorAuthentication.Method.Migration.Create"
            
            public init() {}

            public func prepare(on database: Database) async throws {
                try await database.schema(MultifactorAuthentication.Method.schema)
                    .id()
                    .field(FieldKeys.identityId, .uuid, .required, .references(Identity.schema, "id", onDelete: .cascade))
                    .field(FieldKeys.type, .string, .required)
                    .field(FieldKeys.identifier, .string, .required)
                    .field(FieldKeys.verified, .bool, .required)
                    .field(FieldKeys.createdAt, .datetime)
                    .field(FieldKeys.lastUsedAt, .datetime)
                    .unique(on: FieldKeys.identityId, FieldKeys.type)
                    .create()
            }

            public func revert(on database: Database) async throws {
                try await database.schema(MultifactorAuthentication.Method.schema).delete()
            }
        }
    }
}
