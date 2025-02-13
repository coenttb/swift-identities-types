import Coenttb_Database
import Coenttb_Vapor
import Fluent
import Identity_Provider

extension Database.Identity {
    package final class Deletion: Model, @unchecked Sendable {
        package static let schema = "identity_deletion_state"

        @ID(key: .id)
        package var id: UUID?

        @Parent(key: FieldKeys.identityId)
        package var identity: Database.Identity

        @OptionalField(key: FieldKeys.deletionState)
        package var state: Database.Identity.Deletion.State?

        // The time when the deletion was requested, relevant if the deletionState is pending
        @OptionalField(key: FieldKeys.deletionRequestedAt)
        package var requestedAt: Date?

        package enum FieldKeys {
            static let identityId: FieldKey = "identity_id"
            static let deletionState: FieldKey = "deletion_state"
            static let deletionRequestedAt: FieldKey = "deletion_requested_at"
        }

        package init() {}

        package enum State: String, Codable, Sendable {
            case pending
            case deleted
        }

        package init(
            id: UUID? = nil,
            identity: Database.Identity
        ) throws {
            self.id = id
            self.$identity.id = try identity.requireID()
        }
    }
}

extension Database.Identity.Deletion {
    package struct Migration: AsyncMigration {

        package var name: String = "Coenttb_Identity_Provider.DeletionState"

        package func prepare(on database: Fluent.Database) async throws {
            try await database.schema(Database.Identity.Deletion.schema)
                .id()
                .field(FieldKeys.identityId, .uuid, .required, .references(Database.Identity.schema, "id", onDelete: .cascade))
            //                .field(FieldKeys.newEmail, .string, .required)
            //                .field(FieldKeys.tokenId, .uuid, .required, .references(Identity.Token.schema, "id", onDelete: .cascade))
            //                .unique(on: FieldKeys.tokenId)
                .create()
        }

        package func revert(on database: Fluent.Database) async throws {
            try await database.schema(Database.Identity.Deletion.schema).delete()
        }
    }
}
