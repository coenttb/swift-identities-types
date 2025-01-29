import Coenttb_Vapor
import Coenttb_Database
import Identity_Provider
import Fluent

public final class DeletionState: Model, @unchecked Sendable {
    public static let schema = "email_change_requests"

    @ID(key: .id)
    public var id: UUID?

    @Parent(key: FieldKeys.identityId)
    public var identity: Identity

    @OptionalField(key: FieldKeys.deletionState)
    public var deletionState: DeletionState?

    // The time when the deletion was requested, relevant if the deletionState is pending
    @OptionalField(key: FieldKeys.deletionRequestedAt)
    public var deletionRequestedAt: Date?

    enum FieldKeys {
        static let identityId: FieldKey = "identity_id"
        static let deletionState: FieldKey = "deletion_state"
        static let deletionRequestedAt: FieldKey = "deletion_requested_at"
    }

    public init() {}
    
    public enum DeletionState: String, Codable, Sendable {
        case pending
        case deleted
    }

    public init(
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

    public struct Migration: AsyncMigration {
        
        public var name: String = "Coenttb_Identity_Provider.DeletionState"
        
        public func prepare(on database: Database) async throws {
            try await database.schema(Coenttb_Identity_Provider.DeletionState.schema)
                .id()
                .field(FieldKeys.identityId, .uuid, .required, .references(Identity.schema, "id", onDelete: .cascade))
//                .field(FieldKeys.newEmail, .string, .required)
//                .field(FieldKeys.tokenId, .uuid, .required, .references(Identity.Token.schema, "id", onDelete: .cascade))
//                .unique(on: FieldKeys.tokenId)
                .create()
        }

        public func revert(on database: Database) async throws {
            try await database.schema(Coenttb_Identity_Provider.DeletionState.schema).delete()
        }
    }
}
