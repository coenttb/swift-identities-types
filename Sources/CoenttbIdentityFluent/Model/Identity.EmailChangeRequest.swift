

import Dependencies
@preconcurrency import Fluent
import Foundation
import Vapor
import Fluent
import Vapor

public final class EmailChangeRequest: Model, @unchecked Sendable {
    public static let schema = "email_change_requests"

    @ID(key: .id)
    public var id: UUID?

    @Parent(key: FieldKeys.identityId)
    package var identity: Identity

    @Field(key: FieldKeys.newEmail)
    package var newEmail: String

    @Parent(key: FieldKeys.tokenId)
    package var token: Identity.Token

    enum FieldKeys {
        static let identityId: FieldKey = "identity_id"
        static let newEmail: FieldKey = "new_email"
        static let tokenId: FieldKey = "token_id"
    }

    public init() {}

    package init(id: UUID? = nil, identity: Identity, newEmail: String, token: Identity.Token) throws {
        guard token.type == .emailChange
        else { throw Abort(.badRequest, reason: "Invalid token type for email change") }
        
        self.id = id
        self.$identity.id = try identity.requireID()
        self.newEmail = newEmail
        self.$token.id = try token.requireID()
    }

    public struct Migration: AsyncMigration {
        
        public var name: String = "CoenttbIdentity.EmailChangeRequest.Migration.Create"
        
        public init(){}
        public func prepare(on database: Database) async throws {
            try await database.schema(EmailChangeRequest.schema)
                .id()
                .field(FieldKeys.identityId, .uuid, .required, .references(Identity.schema, "id", onDelete: .cascade))
                .field(FieldKeys.newEmail, .string, .required)
                .field(FieldKeys.tokenId, .uuid, .required, .references(Identity.Token.schema, "id", onDelete: .cascade))
                .unique(on: FieldKeys.tokenId)
                .create()
        }

        public func revert(on database: Database) async throws {
            try await database.schema(EmailChangeRequest.schema).delete()
        }
    }
}
