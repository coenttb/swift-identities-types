import Dependencies
@preconcurrency import Fluent
import Foundation
@preconcurrency import Vapor

extension Database {
    package final class ApiKey: Model, Content, @unchecked Sendable {
        package static let schema = "api_keys"

        @ID(key: .id)
        package var id: UUID?

        @Field(key: FieldKeys.name)
        package var name: String

        @Field(key: FieldKeys.key)
        package var key: String

        @Field(key: FieldKeys.scopes)
        package var scopes: [String]

        @Parent(key: FieldKeys.identityId)
        package var identity: Identity

        @Field(key: FieldKeys.isActive)
        package var isActive: Bool

        @Field(key: FieldKeys.rateLimit)
        package var rateLimit: Int

        @Field(key: FieldKeys.validUntil)
        package var validUntil: Date

        @Timestamp(key: FieldKeys.createdAt, on: .create)
        package var createdAt: Date?

        @OptionalField(key: FieldKeys.lastUsedAt)
        package var lastUsedAt: Date?

        package enum FieldKeys {
            static let name: FieldKey = "name"
            static let key: FieldKey = "key"
            static let scopes: FieldKey = "scopes"
            static let identityId: FieldKey = "identity_id"
            static let isActive: FieldKey = "is_active"
            static let rateLimit: FieldKey = "rate_limit"
            static let validUntil: FieldKey = "valid_until"
            static let createdAt: FieldKey = "created_at"
            static let lastUsedAt: FieldKey = "last_used_at"
        }

        package init() {}

        package init(
            id: UUID? = nil,
            name: String,
            identity: Identity,
            scopes: [String] = [],
            rateLimit: Int = 1000,
            validUntil: Date = {
                @Dependency(\.date) var date
                return date()
            }().addingTimeInterval(365 * 24 * 3600)
        ) throws {
            self.id = id
            self.name = name
            self.$identity.id = try identity.requireID()
            self.key = ApiKey.generateKey()
            self.scopes = scopes
            self.isActive = true
            self.rateLimit = rateLimit
            self.validUntil = validUntil
        }

        private static func generateKey() -> String {
           @Dependency(\.envVars.appEnv) var appEnv
           @Dependency(\.uuid) var uuid

           let prefix = "pk_"

           if appEnv == .development {
               let generatedUuid = uuid()
               print("Generated UUID: \(generatedUuid)")
               return "\(prefix)test_\(generatedUuid.uuidString)"
           } else {
               let randomBytes = SymmetricKey(size: .bits256)
               return prefix + Data(randomBytes.withUnsafeBytes { Data($0) }).base64EncodedString()
           }
        }
    }
}

extension Database.ApiKey {
    package enum Migration {
        package struct Create: AsyncMigration {

            package var name: String = "Identity_Provider.ApiKey.Migration.Create"

            package func prepare(on database: Fluent.Database) async throws {
                try await database.schema(Database.ApiKey.schema)
                    .id()
                    .field(FieldKeys.name, .string, .required)
                    .field(FieldKeys.key, .string, .required)
                    .field(FieldKeys.scopes, .array(of: .string), .required)
                    .field(FieldKeys.identityId, .uuid, .required, .references(Database.Identity.schema, "id", onDelete: .cascade))
                    .field(FieldKeys.isActive, .bool, .required)
                    .field(FieldKeys.rateLimit, .int, .required)
                    .field(FieldKeys.validUntil, .datetime, .required)
                    .field(FieldKeys.createdAt, .datetime)
                    .field(FieldKeys.lastUsedAt, .datetime)
                    .unique(on: FieldKeys.key)
                    .create()
            }

            package func revert(on database: Fluent.Database) async throws {
                try await database.schema(Database.ApiKey.schema).delete()
            }

            package init() {}
        }
    }
}
