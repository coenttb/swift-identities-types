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

// MultifactorAuthentication.RecoveryCode.swift
extension Database.MultifactorAuthentication {
    package final class RecoveryCode: Model, Content, @unchecked Sendable {
        package static let schema = "mfa_recovery_codes"

        @ID(key: .id)
        package var id: UUID?

        @Parent(key: FieldKeys.identityId)
        package var identity: Database.Identity

        @Field(key: FieldKeys.code)
        package var code: String

        @Field(key: FieldKeys.used)
        package var used: Bool

        @OptionalField(key: FieldKeys.usedAt)
        package var usedAt: Date?

        package enum FieldKeys {
            package static let identityId: FieldKey = "identity_id"
            package static let code: FieldKey = "code"
            package static let used: FieldKey = "used"
            package static let usedAt: FieldKey = "used_at"
        }

        package init() {}

        package init(
            id: UUID? = nil,
            identity: Database.Identity,
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

extension Database.MultifactorAuthentication.RecoveryCode {
    package enum Migration {
        package struct Create: AsyncMigration {
            package var name: String = "Identity_Provider.MultifactorAuthentication.RecoveryCode.Migration.Create"

            package init() {}

            package func prepare(on database: Fluent.Database) async throws {
                try await database.schema(Database.MultifactorAuthentication.RecoveryCode.schema)
                    .id()
                    .field(FieldKeys.identityId, .uuid, .required, .references(Database.Identity.schema, "id", onDelete: .cascade))
                    .field(FieldKeys.code, .string, .required)
                    .field(FieldKeys.used, .bool, .required)
                    .field(FieldKeys.usedAt, .datetime)
                    .create()
            }

            package func revert(on database: Fluent.Database) async throws {
                try await database.schema(Database.MultifactorAuthentication.RecoveryCode.schema).delete()
            }
        }
    }
}
