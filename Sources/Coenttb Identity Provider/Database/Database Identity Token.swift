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
    public final class Token: Model, Content, @unchecked Sendable  {
        public static let schema = "identity_tokens"
        
        @ID(key: .id)
        public var id: UUID?
        
        @Field(key: FieldKeys.value)
        public var value: String
        
        @Field(key: FieldKeys.validUntil)
        public var validUntil: Date
        
        @Parent(key: FieldKeys.identityId)
        public var identity: Database.Identity
        
        @Enum(key: FieldKeys.type)
        public var type: Database.Identity.Token.TokenType
        
        @Timestamp(key: FieldKeys.createdAt, on: .create)
        public var createdAt: Date?
        
        @OptionalField(key: FieldKeys.lastUsedAt)
        public var lastUsedAt: Date?
        
        package enum FieldKeys {
            public static let value: FieldKey = "value"
            public static let validUntil: FieldKey = "valid_until"
            public static let identityId: FieldKey = "identity_id"
            public static let type: FieldKey = "type"
            public static let createdAt: FieldKey = "created_at"
            public static let lastUsedAt: FieldKey = "last_used_at"
        }
        
        public struct TokenType: Codable, Equatable, RawRepresentable, Sendable {
            public let rawValue: String
            
            public init(rawValue: String) {
                self.rawValue = rawValue
            }
            
            public init(_ rawValue: String) {
                self.rawValue = rawValue
            }
            
            public static let emailVerification = TokenType("emailVerification")
            public static let passwordReset = TokenType("passwordReset")
            public static let accountActivation = TokenType("accountActivation")
            public static let twoFactorAuthentication = TokenType("twoFactorAuthentication")
            public static let apiAccess = TokenType("apiAccess")
            public static let refreshToken = TokenType("refreshToken")
            public static let sessionToken = TokenType("sessionToken")
            public static let rememberMeToken = TokenType("rememberMeToken")
            public static let invitationToken = TokenType("invitationToken")
            public static let passwordlessLogin = TokenType("passwordlessLogin")
            public static let accountDeletion = TokenType("accountDeletion")
            public static let emailChange = TokenType("emailChange")
            public static let phoneNumberVerification = TokenType("phoneNumberVerification")
            public static let termsAcceptance = TokenType("termsAcceptance")
            public static let consentToken = TokenType("consentToken")
            public static let temporaryAccess = TokenType("temporaryAccess")
            public static let reauthenticationToken = TokenType("reauthenticationToken")
        }
        
        public init() {}
        
        public init(
            id: UUID? = nil,
            identity: Database.Identity,
            type: Database.Identity.Token.TokenType,
            validUntil: Date? = nil
        ) throws {
            self.id = id
            self.$identity.id = try identity.requireID()
            self.type = type
            self.value = Database.Identity.Token.generateSecureToken()
            self.validUntil = validUntil ?? Date().addingTimeInterval(3600) // Default 1 hour validity
        }
        
        private static func generateSecureToken() -> String {
            SymmetricKey(size: .bits256)
                .withUnsafeBytes { Data($0) }
                .base64EncodedString()
        }
    }
}





//extension Database.Identity.Token: ModelTokenAuthenticatable {
//    public static var valueKey: KeyPath<Database.Identity.Token, Field<String>> {
//        \Database.Identity.Token.$value
//    }
//    
//    public static var userKey: KeyPath<Database.Identity.Token, Parent<Database.Identity>> {
//        \Database.Identity.Token.$identity
//    }
//    
//    public var isValid: Bool {
//        Date() < self.validUntil
//    }
//}

extension Database.Identity.Token {
    public func rotateIfNecessary(on db: Fluent.Database) async throws -> Database.Identity.Token {
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
    public func generateToken(type: Database.Identity.Token.TokenType, validUntil: Date? = nil) throws -> Database.Identity.Token {
        try .init(
            identity: self,
            type: type,
            validUntil: validUntil
        )
    }
}

extension Database.Identity.Token {
    public struct Migration: AsyncMigration {
        
        public var name: String = "Coenttb_Identity.Identity.Token.Migration.Create"
        
        public init(){}
        
        public func prepare(on database: Fluent.Database) async throws {
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
        
        public func revert(on database: Fluent.Database) async throws {
            try await database.schema(Database.Identity.Token.schema).delete()
        }
    }
}

extension Database.Identity {
    private static let tokenGenerationLimit = 5
    private static let tokenGenerationWindow: TimeInterval = 3600 // 1 hour

    public func canGenerateToken(on db: Fluent.Database) async throws -> Bool {
        let recentTokens = try await Database.Identity.Token.query(on: db)
            .filter(\.$identity.$id == self.id!)
            .filter(\.$createdAt >= Date().addingTimeInterval(-Self.tokenGenerationWindow))
            .count()

        return recentTokens < Self.tokenGenerationLimit
    }
}
