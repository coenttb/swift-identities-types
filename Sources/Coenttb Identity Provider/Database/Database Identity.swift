import Dependencies
import EmailAddress
@preconcurrency import Fluent
import Foundation
@preconcurrency import Vapor

extension Database {
    public final class Identity: Model, Content, @unchecked Sendable {
        public static let schema = "identities"

        @ID(key: .id)
        public var id: UUID?

        @Field(key: FieldKeys.email)
        public internal(set) var email: String

        @Field(key: FieldKeys.passwordHash)
        package var passwordHash: String

        @Enum(key: FieldKeys.emailVerificationStatus)
        package var emailVerificationStatus: EmailVerificationStatus

        @Field(key: FieldKeys.sessionVersion)
        package var sessionVersion: Int

        @Timestamp(key: FieldKeys.createdAt, on: .create)
        package var createdAt: Date?

        @Timestamp(key: FieldKeys.updatedAt, on: .update)
        package var updatedAt: Date?

        @OptionalField(key: FieldKeys.lastLoginAt)
        package var lastLoginAt: Date?

        public var emailAddress: EmailAddress {
            get {
                try! EmailAddress(self.email)
            }
            set {
                self.email = newValue.rawValue
            }
        }

        @OptionalChild(for: \.$identity)
        package var deletion: Database.Identity.Deletion?

        package enum FieldKeys {
            package static let email: FieldKey = "email"
            package static let passwordHash: FieldKey = "password_hash"
            package static let emailVerificationStatus: FieldKey = "email_verification_status"
            package static let createdAt: FieldKey = "created_at"
            package static let updatedAt: FieldKey = "updated_at"
            package static let lastLoginAt: FieldKey = "last_login_at"
            package static let sessionVersion: FieldKey = "session-version"
        }

        public enum EmailVerificationStatus: String, Codable, Sendable {
            case unverified
            case pending
            case verified
            case failed
        }

        public init() {}

        package init(
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

// extension Database.Identity: ModelAuthenticatable {
//    package static var usernameKey: KeyPath<Database.Identity, Field<String>> {
//        \Database.Identity.$email
//    }
//
//    package static var passwordHashKey: KeyPath<Database.Identity, Field<String>> {
//        \Database.Identity.$passwordHash
//    }
//
//    package func verify(password: String) throws -> Bool {
//        try Bcrypt.verify(password, created: self.passwordHash) && self.emailVerificationStatus == .verified
//    }
// }
//
// extension Database.Identity: ModelCredentialsAuthenticatable {}
//
// extension Database.Identity: ModelSessionAuthenticatable {}

extension Database.Identity {
    package enum Migration {
        package struct Create: AsyncMigration {

            package var name: String = "Coenttb_Identity.Identity.Migration.Create"

            package init() {}

            package func prepare(on database: Fluent.Database) async throws {
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

            package func revert(on database: Fluent.Database) async throws {
                try await database.schema(Database.Identity.schema).delete()
            }
        }
    }
}

extension Database.Identity {
    package func setPassword(_ password: String) throws {
        self.passwordHash = try Bcrypt.hash(password)
    }

    package func verifyPassword(_ password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}
