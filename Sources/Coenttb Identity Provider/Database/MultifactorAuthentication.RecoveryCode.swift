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

// MultifactorAuthentication.RecoveryCode.swift
extension MultifactorAuthentication {
    public final class RecoveryCode: Model, Content, @unchecked Sendable {
        public static let schema = "mfa_recovery_codes"

        @ID(key: .id)
        public var id: UUID?

        @Parent(key: FieldKeys.identityId)
        public var identity: Identity

        @Field(key: FieldKeys.code)
        public var code: String

        @Field(key: FieldKeys.used)
        public var used: Bool

        @OptionalField(key: FieldKeys.usedAt)
        public var usedAt: Date?

        public enum FieldKeys {
            public static let identityId: FieldKey = "identity_id"
            public static let code: FieldKey = "code"
            public static let used: FieldKey = "used"
            public static let usedAt: FieldKey = "used_at"
        }

        public init() {}

        public init(
            id: UUID? = nil,
            identity: Identity,
            code: String,
            used: Bool = false
        ) throws {
            self.id = id
            self.$identity.id = try identity.requireID()
            self.code = code
            self.used = used
        }
    }
}


extension MultifactorAuthentication.RecoveryCode {
    public enum Migration {
        public struct Create: AsyncMigration {
            public var name: String = "Identity_Provider.MultifactorAuthentication.RecoveryCode.Migration.Create"
            
            public init() {}

            public func prepare(on database: Database) async throws {
                try await database.schema(MultifactorAuthentication.RecoveryCode.schema)
                    .id()
                    .field(FieldKeys.identityId, .uuid, .required, .references(Identity.schema, "id", onDelete: .cascade))
                    .field(FieldKeys.code, .string, .required)
                    .field(FieldKeys.used, .bool, .required)
                    .field(FieldKeys.usedAt, .datetime)
                    .create()
            }

            public func revert(on database: Database) async throws {
                try await database.schema(MultifactorAuthentication.RecoveryCode.schema).delete()
            }
        }
    }
}
