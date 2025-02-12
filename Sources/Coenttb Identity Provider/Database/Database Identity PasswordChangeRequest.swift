

import Dependencies
@preconcurrency import Fluent
import Foundation
import Vapor
import Fluent
import Vapor

extension Database {
    package final class PasswordChangeRequest: Model, @unchecked Sendable {
        package static let schema = "password_change_requests"
        
        @ID(key: .id)
        package var id: UUID?
        
        @Parent(key: FieldKeys.identityId)
        package var identity: Database.Identity
        
        @Field(key: FieldKeys.newEmail)
        package var newEmail: String
        
        @Parent(key: FieldKeys.tokenId)
        package var token: Database.Identity.Token
        
        package enum FieldKeys {
            static let identityId: FieldKey = "identity_id"
            static let newEmail: FieldKey = "new_password"
            static let tokenId: FieldKey = "token_id"
        }
        
        package init() {}
        
        package init(
            id: UUID? = nil,
            identity: Database.Identity,
            newEmail: String,
            token: Database.Identity.Token
        ) throws {
            guard token.type == .passwordReset
            else { throw Abort(.badRequest, reason: "Invalid token type for password change") }
            
            self.id = id
            self.$identity.id = try identity.requireID()
            self.newEmail = newEmail
            self.$token.id = try token.requireID()
        }
    }
}

extension Database.PasswordChangeRequest {
    package struct Migration: AsyncMigration {
        
        package var name: String = "Coenttb_Identity.PasswordChangeRequest.Migration.Create"
        
        package init(){}
        package func prepare(on database: Fluent.Database) async throws {
            try await database.schema(Database.PasswordChangeRequest.schema)
                .id()
                .field(FieldKeys.identityId, .uuid, .required, .references(Database.Identity.schema, "id", onDelete: .cascade))
                .field(FieldKeys.newEmail, .string, .required)
                .field(FieldKeys.tokenId, .uuid, .required, .references(Database.Identity.Token.schema, "id", onDelete: .cascade))
                .unique(on: FieldKeys.tokenId)
                .create()
        }
        
        package func revert(on database: Fluent.Database) async throws {
            try await database.schema(Database.PasswordChangeRequest.schema).delete()
        }
    }
}
