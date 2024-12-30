import Coenttb_Vapor
import Coenttb_Database
import Coenttb_Identity
import Coenttb_Identity_Live

package final class DeletionState: Model, @unchecked Sendable {
    package static let schema = "email_change_requests"

    @ID(key: .id)
    package var id: UUID?

    @Parent(key: FieldKeys.identityId)
    package var identity: Identity

    @OptionalField(key: FieldKeys.deletionState)
    package var deletionState: DeletionState?

    // The time when the deletion was requested, relevant if the deletionState is pending
    @OptionalField(key: FieldKeys.deletionRequestedAt)
    package var deletionRequestedAt: Date?

    enum FieldKeys {
        static let identityId: FieldKey = "identity_id"
        static let deletionState: FieldKey = "deletion_state"
        static let deletionRequestedAt: FieldKey = "deletion_requested_at"
    }

    package init() {}
    
    package enum DeletionState: String, Codable {
        case pending
        case deleted
    }

    package init(
        id: UUID? = nil,
        identity: Identity,
        newEmail: String,
        token: Identity.Token
    ) throws {
        self.id = id
        self.$identity.id = try identity.requireID()
//        self.newEmail = newEmail
//        self.$token.id = try token.requireID()
    }

    package struct Migration: AsyncMigration {
        
        package var name: String = "Coenttb_Identity_Fluent.DeletionState"
        
        package func prepare(on database: Database) async throws {
            try await database.schema(Coenttb_Identity_Fluent.DeletionState.schema)
                .id()
                .field(FieldKeys.identityId, .uuid, .required, .references(Identity.schema, "id", onDelete: .cascade))
//                .field(FieldKeys.newEmail, .string, .required)
//                .field(FieldKeys.tokenId, .uuid, .required, .references(Identity.Token.schema, "id", onDelete: .cascade))
//                .unique(on: FieldKeys.tokenId)
                .create()
        }

        package func revert(on database: Database) async throws {
            try await database.schema(Coenttb_Identity_Fluent.DeletionState.schema).delete()
        }
    }
}
