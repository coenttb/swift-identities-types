import Dependencies
@preconcurrency import Fluent
import Foundation
@preconcurrency import Vapor
import EmailAddress

extension Database {
    public final class Identity: Model, Content, @unchecked Sendable {
        public static let schema = "identities"

        @ID(key: .id)
        public var id: UUID?
        
        @Field(key: FieldKeys.email)
        public internal(set) var email: String
        
        @Field(key: FieldKeys.passwordHash)
        public var passwordHash: String

        @Enum(key: FieldKeys.emailVerificationStatus)
        public var emailVerificationStatus: EmailVerificationStatus
        
        @Field(key: FieldKeys.sessionVersion)
        public var sessionVersion: Int
        
        @Timestamp(key: FieldKeys.createdAt, on: .create)
        public var createdAt: Date?
        
        @Timestamp(key: FieldKeys.updatedAt, on: .update)
        public var updatedAt: Date?
        
        @OptionalField(key: FieldKeys.lastLoginAt)
        public var lastLoginAt: Date?
        
        public var emailAddress: EmailAddress {
            get {
                try! EmailAddress(self.email)
            }
            set {
                self.email = newValue.rawValue
            }
        }
        
        @OptionalChild(for: \.$identity)
        public var deletion: Database.Identity.Deletion?

        package enum FieldKeys {
            public static let email: FieldKey = "email"
            public static let passwordHash: FieldKey = "password_hash"
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
            email: EmailAddress,
            password: String,
            emailVerificationStatus: EmailVerificationStatus = .unverified,
            sessionVersion: Int = 0
        ) throws {
            self.id = id
            self.email = email.rawValue
            self.passwordHash = try Bcrypt.hash(password)
            self.emailVerificationStatus = emailVerificationStatus
            self.sessionVersion = sessionVersion
        }
    }
}

extension Database.Identity: Authenticatable {}

//extension Database.Identity: ModelAuthenticatable {
//    public static var usernameKey: KeyPath<Database.Identity, Field<String>> {
//        \Database.Identity.$email
//    }
//
//    public static var passwordHashKey: KeyPath<Database.Identity, Field<String>> {
//        \Database.Identity.$passwordHash
//    }
//
//    public func verify(password: String) throws -> Bool {
//        try Bcrypt.verify(password, created: self.passwordHash) && self.emailVerificationStatus == .verified
//    }
//}
//
//extension Database.Identity: ModelCredentialsAuthenticatable {}
//
//extension Database.Identity: ModelSessionAuthenticatable {}

extension Database.Identity {
    public enum Migration {
        public struct Create: AsyncMigration {
            
            public var name:String = "Coenttb_Identity.Identity.Migration.Create"
            
            public init() {}

            public func prepare(on database: Fluent.Database) async throws {
                try await database.schema(Database.Identity.schema)
                    .id()
                    .field(FieldKeys.email, .string, .required)
                    .unique(on: FieldKeys.email)
                    .field(FieldKeys.passwordHash, .string, .required)
                    .field(FieldKeys.emailVerificationStatus, .string, .required)
                    .field(FieldKeys.createdAt, .datetime)
                    .field(FieldKeys.updatedAt, .datetime)
                    .field(FieldKeys.sessionVersion, .int, .required, .custom("DEFAULT 0"))
                    .field(FieldKeys.lastLoginAt, .datetime)
                    .create()
            }

            public func revert(on database: Fluent.Database) async throws {
                try await database.schema(Database.Identity.schema).delete()
            }
        }
    }
}





extension Database.Identity {
    public func setPassword(_ password: String) throws {
        self.passwordHash = try Bcrypt.hash(password)
    }
    
    public func verifyPassword(_ password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

