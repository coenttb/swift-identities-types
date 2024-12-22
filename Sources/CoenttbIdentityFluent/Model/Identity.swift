import Dependencies
@preconcurrency import Fluent
import Foundation
@preconcurrency import Vapor

public final class Identity: Model, Content, @unchecked Sendable {
    public static let schema = "identities"

    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: FieldKeys.email)
    public var email: String
    
    @Field(key: FieldKeys.passwordHash)
    public var passwordHash: String
    
    @OptionalField(key: FieldKeys.name)
    public var name: String?
    
    @Field(key: FieldKeys.isAdmin)
    public var isAdmin: Bool
    
    @Field(key: FieldKeys.emailVerificationStatus)
    public var emailVerificationStatus: EmailVerificationStatus
    
    @Field(key: FieldKeys.sessionVersion)
    public var sessionVersion: Int
    
    @Timestamp(key: FieldKeys.createdAt, on: .create)
    public var createdAt: Date?
    
    @Timestamp(key: FieldKeys.updatedAt, on: .update)
    public var updatedAt: Date?
    
    @OptionalField(key: FieldKeys.lastLoginAt)
    public var lastLoginAt: Date?

    public enum FieldKeys {
        public static let email: FieldKey = "email"
        public static let passwordHash: FieldKey = "password_hash"
        public static let name: FieldKey = "name"
        public static let isAdmin: FieldKey = "is_admin"
        public static let emailVerificationStatus: FieldKey = "email_verification_status"
        public static let createdAt: FieldKey = "created_at"
        public static let updatedAt: FieldKey = "updated_at"
        public static let lastLoginAt: FieldKey = "last_login_at"
        public static let sessionVersion: FieldKey = "session-version"
    }
    
    public enum EmailVerificationStatus: String, Codable, Sendable {
        case unverified
        case pending
        case verified
        case failed
    }

    public init() {}

    public init(
        id: UUID? = nil,
        email: String,
        password: String,
        name: String? = nil,
        isAdmin: Bool = false,
        emailVerificationStatus: EmailVerificationStatus = .unverified,
        sessionVersion: Int = 0
    ) throws {
        self.id = id
        self.email = email
        self.passwordHash = try Bcrypt.hash(password)
        self.name = name
        self.isAdmin = isAdmin
        self.emailVerificationStatus = emailVerificationStatus
        self.sessionVersion = sessionVersion
    }
}

extension Identity {
    public enum Migration {
        public struct Create: AsyncMigration {
            
            public var name: String = "CoenttbIdentity.Identity.Migration"
            
            public init() {}

            public func prepare(on database: Database) async throws {
                try await database.schema(Identity.schema)
                    .id()
                    .field(FieldKeys.email, .string, .required)
                    .unique(on: FieldKeys.email)
                    .field(FieldKeys.passwordHash, .string, .required)
                    .field(FieldKeys.name, .string)
                    .field(FieldKeys.isAdmin, .bool, .required, .custom("DEFAULT FALSE"))
                    .field(FieldKeys.emailVerificationStatus, .string, .required)
                    .field(FieldKeys.createdAt, .datetime)
                    .field(FieldKeys.updatedAt, .datetime)
                    .field(FieldKeys.sessionVersion, .int, .required, .custom("DEFAULT 0"))
                    .field(FieldKeys.lastLoginAt, .datetime)
                    .create()
            }

            public func revert(on database: Database) async throws {
                try await database.schema(Identity.schema).delete()
            }
        }
    }
}

extension Identity: ModelAuthenticatable {
    public static var usernameKey: KeyPath<Identity, Field<String>> {
        \Identity.$email
    }

    public static var passwordHashKey: KeyPath<Identity, Field<String>> {
        \Identity.$passwordHash
    }

    public func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash) && self.emailVerificationStatus == .verified
    }
}

extension Identity: ModelCredentialsAuthenticatable {}

extension Identity: ModelSessionAuthenticatable {}

extension Identity {
    public func generateToken(type: Identity.Token.TokenType, validUntil: Date? = nil) throws -> Identity.Token {
        try .init(
            identity: self,
            type: type,
            validUntil: validUntil
        )
    }
}

extension Identity {
    private static let tokenGenerationLimit = 5
    private static let tokenGenerationWindow: TimeInterval = 3600 // 1 hour

    public func canGenerateToken(on db: Database) async throws -> Bool {
        let recentTokens = try await Identity.Token.query(on: db)
            .filter(\.$identity.$id == self.id!)
            .filter(\.$createdAt >= Date().addingTimeInterval(-Self.tokenGenerationWindow))
            .count()

        return recentTokens < Self.tokenGenerationLimit
    }
}

extension Identity {
    public func setPassword(_ password: String) throws {
        self.passwordHash = try Bcrypt.hash(password)
    }
    
    public func verifyPassword(_ password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

extension Identity {
    public struct SessionAuthenticator: AsyncSessionAuthenticator {
        public typealias User = Identity
        
        public init() {}

        
        public func authenticate(sessionID: UUID, for request: Request) async throws {
            guard let identity = try await Identity.find(sessionID, on: request.db)
            else { return }
            
            if
                let storedVersion = request.session.data[Identity.FieldKeys.sessionVersion.description].flatMap({ Int($0) }),
                storedVersion != identity.sessionVersion {
                request.session.unauthenticate(Identity.self)
                return
            }
            
            identity.lastLoginAt = Date()
            try await identity.save(on: request.db)
            
            request.auth.login(identity)
            
            request.session.data[Identity.FieldKeys.sessionVersion.description] = "\(identity.sessionVersion)"
        }
    }
}

