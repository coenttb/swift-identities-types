//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 12/09/2024.
//

import Dependencies
@preconcurrency import Fluent
import Foundation
import Vapor

extension Database.Identity {
    package final class Token: Model, Content, @unchecked Sendable {
        package static let schema = "identity_tokens"

        @ID(key: .id)
        package var id: UUID?

        @Field(key: FieldKeys.value)
        package var value: String

        @Field(key: FieldKeys.validUntil)
        package var validUntil: Date

        @Parent(key: FieldKeys.identityId)
        package var identity: Database.Identity

        @Enum(key: FieldKeys.type)
        package var type: Database.Identity.Token.TokenType

        @Timestamp(key: FieldKeys.createdAt, on: .create)
        package var createdAt: Date?

        @OptionalField(key: FieldKeys.lastUsedAt)
        package var lastUsedAt: Date?

        package enum FieldKeys {
            package static let value: FieldKey = "value"
            package static let validUntil: FieldKey = "valid_until"
            package static let identityId: FieldKey = "identity_id"
            package static let type: FieldKey = "type"
            package static let createdAt: FieldKey = "created_at"
            package static let lastUsedAt: FieldKey = "last_used_at"
        }

        package struct TokenType: Codable, Equatable, RawRepresentable, Sendable {
            package let rawValue: String

            package init(rawValue: String) {
                self.rawValue = rawValue
            }

            package init(_ rawValue: String) {
                self.rawValue = rawValue
            }

            package static let emailVerification = TokenType("emailVerification")
            package static let passwordReset = TokenType("passwordReset")
            package static let accountActivation = TokenType("accountActivation")
            package static let twoFactorAuthentication = TokenType("twoFactorAuthentication")
            package static let apiAccess = TokenType("apiAccess")
            package static let refreshToken = TokenType("refreshToken")
            package static let sessionToken = TokenType("sessionToken")
            package static let rememberMeToken = TokenType("rememberMeToken")
            package static let invitationToken = TokenType("invitationToken")
            package static let passwordlessLogin = TokenType("passwordlessLogin")
            package static let accountDeletion = TokenType("accountDeletion")
            package static let emailChange = TokenType("emailChange")
            package static let phoneNumberVerification = TokenType("phoneNumberVerification")
            package static let termsAcceptance = TokenType("termsAcceptance")
            package static let consentToken = TokenType("consentToken")
            package static let temporaryAccess = TokenType("temporaryAccess")
            package static let reauthenticationToken = TokenType("reauthenticationToken")
        }

        package init() {}

        package init(
            id: UUID? = nil,
            identity: Database.Identity,
            type: Database.Identity.Token.TokenType,
            validUntil: Date? = nil
        ) throws {
            self.id = id
            self.$identity.id = try identity.requireID()
            self.type = type
            self.value = Database.Identity.Token.generateSecureToken(type: type)
            self.validUntil = validUntil ?? Date().addingTimeInterval(3600) // Default 1 hour validity
        }

        private static func generateSecureToken(type: Database.Identity.Token.TokenType) -> String {
            switch type {
            case .emailVerification:
                SymmetricKey(size: .bits256)
                    .withUnsafeBytes { Data($0) }
                    .base64EncodedString()
                    .replacingOccurrences(of: "+", with: "-")
                    .replacingOccurrences(of: "/", with: "_")
                    .replacingOccurrences(of: "=", with: "")
            default:
                SymmetricKey(size: .bits256)
                    .withUnsafeBytes { Data($0) }
                    .base64EncodedString()
            }
        }
    }
}

// extension Database.Identity.Token: ModelTokenAuthenticatable {
//    package static var valueKey: KeyPath<Database.Identity.Token, Field<String>> {
//        \Database.Identity.Token.$value
//    }
//    
//    package static var userKey: KeyPath<Database.Identity.Token, Parent<Database.Identity>> {
//        \Database.Identity.Token.$identity
//    }
//    
//    package var isValid: Bool {
//        Date() < self.validUntil
//    }
// }

extension Database.Identity.Token {
    package func rotateIfNecessary(on db: Fluent.Database) async throws -> Database.Identity.Token {
        guard self.type == .apiAccess || self.type == .refreshToken else {
            return self
        }

        let rotationInterval: TimeInterval = 7 * 24 * 3600 // 7 days
        if Date().timeIntervalSince(self.createdAt ?? Date()) > rotationInterval {
            try await self.delete(on: db)
            return try self.identity.generateToken(type: self.type, validUntil: Date().addingTimeInterval(30 * 24 * 3600)) // 30 days
        }

        return self
    }
}

extension Database.Identity {
    package func generateToken(type: Database.Identity.Token.TokenType, validUntil: Date? = nil) throws -> Database.Identity.Token {
        try .init(
            identity: self,
            type: type,
            validUntil: validUntil
        )
    }
}

extension Database.Identity.Token {
    package struct Migration: AsyncMigration {

        package var name: String = "Coenttb_Identity.Identity.Token.Migration.Create"

        package init() {}

        package func prepare(on database: Fluent.Database) async throws {
            try await database.schema(Database.Identity.Token.schema)
                .id()
                .field(FieldKeys.value, .string, .required)
                .field(FieldKeys.validUntil, .datetime, .required)
                .field(FieldKeys.identityId, .uuid, .required, .references(Database.Identity.schema, "id", onDelete: .cascade))
                .field(FieldKeys.type, .string, .required)
                .field(FieldKeys.createdAt, .datetime, .required)
                .field(FieldKeys.lastUsedAt, .datetime)
                .unique(on: FieldKeys.value)
                .create()
        }

        package func revert(on database: Fluent.Database) async throws {
            try await database.schema(Database.Identity.Token.schema).delete()
        }
    }
}

extension Database.Identity {
    private static let tokenGenerationLimit = 5
    private static let tokenGenerationWindow: TimeInterval = 3600 // 1 hour

    package func canGenerateToken(on db: Fluent.Database) async throws -> Bool {
        let recentTokens = try await Database.Identity.Token.query(on: db)
            .filter(\.$identity.$id == self.id!)
            .filter(\.$createdAt >= Date().addingTimeInterval(-Self.tokenGenerationWindow))
            .count()

        return recentTokens < Self.tokenGenerationLimit
    }
}
