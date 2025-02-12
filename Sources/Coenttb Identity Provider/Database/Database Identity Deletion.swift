import Coenttb_Vapor
import Coenttb_Database
import Identity_Provider
import Fluent

extension Database.Identity {
    public final class Deletion: Model, @unchecked Sendable {
        public static let schema = "identity_deletion_state"
        
        @ID(key: .id)
        public var id: UUID?
        
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
        
        public init() {}
        
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
    public struct Migration: AsyncMigration {
        
        public var name: String = "Coenttb_Identity_Provider.DeletionState"
        
        public func prepare(on database: Fluent.Database) async throws {
            try await database.schema(Database.Identity.Deletion.schema)
                .id()
                .field(FieldKeys.identityId, .uuid, .required, .references(Database.Identity.schema, "id", onDelete: .cascade))
            //                .field(FieldKeys.newEmail, .string, .required)
            //                .field(FieldKeys.tokenId, .uuid, .required, .references(Identity.Token.schema, "id", onDelete: .cascade))
            //                .unique(on: FieldKeys.tokenId)
                .create()
        }
        
        public func revert(on database: Fluent.Database) async throws {
            try await database.schema(Database.Identity.Deletion.schema).delete()
        }
    }
}



