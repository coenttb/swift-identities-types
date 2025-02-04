import Coenttb_Vapor
import Coenttb_Database
import Identity_Provider
import Fluent

extension Identity {
    public final class Deletion: Model, @unchecked Sendable {
        public static let schema = "identity_deletion_state"

        @ID(key: .id)
        public var id: UUID?

        @Parent(key: FieldKeys.identityId)
        public var identity: Identity

        @OptionalField(key: FieldKeys.deletionState)
        public var state: Identity.Deletion.State?

        // The time when the deletion was requested, relevant if the deletionState is pending
        @OptionalField(key: FieldKeys.deletionRequestedAt)
        public var requestedAt: Date?

        enum FieldKeys {
            static let identityId: FieldKey = "identity_id"
            static let deletionState: FieldKey = "deletion_state"
            static let deletionRequestedAt: FieldKey = "deletion_requested_at"
        }

        public init() {}
        
        public enum State: String, Codable, Sendable {
            case pending
            case deleted
        }

        public init(
            id: UUID? = nil,
            identity: Identity
        ) throws {
            self.id = id
            self.$identity.id = try identity.requireID()
        }

        public struct Migration: AsyncMigration {
            
            public var name: String = "Coenttb_Identity_Provider.DeletionState"
            
            public func prepare(on database: Database) async throws {
                try await database.schema(Coenttb_Identity_Provider.Identity.Deletion.schema)
                    .id()
                    .field(FieldKeys.identityId, .uuid, .required, .references(Identity.schema, "id", onDelete: .cascade))
    //                .field(FieldKeys.newEmail, .string, .required)
    //                .field(FieldKeys.tokenId, .uuid, .required, .references(Identity.Token.schema, "id", onDelete: .cascade))
    //                .unique(on: FieldKeys.tokenId)
                    .create()
            }

            public func revert(on database: Database) async throws {
                try await database.schema(Coenttb_Identity_Provider.Identity.Deletion.schema).delete()
            }
        }
    }
}


