import Dependencies
@preconcurrency import Fluent
import Foundation
@preconcurrency import Vapor

public final class ApiKey: Model, Content, @unchecked Sendable {
    public static let schema = "api_keys"

    @ID(key: .id)
    public var id: UUID?
    
    @Field(key: FieldKeys.name)
    public var name: String
    
    @Field(key: FieldKeys.key)
    public var key: String
    
    @Field(key: FieldKeys.scopes)
    public var scopes: [String]
    
    @Parent(key: FieldKeys.identityId)
    public var identity: Identity
    
    @Field(key: FieldKeys.isActive)
    public var isActive: Bool
    
    @Field(key: FieldKeys.rateLimit)
    public var rateLimit: Int
    
    @Field(key: FieldKeys.validUntil)
    public var validUntil: Date
    
    @Timestamp(key: FieldKeys.createdAt, on: .create)
    public var createdAt: Date?
    
    @OptionalField(key: FieldKeys.lastUsedAt)
    public var lastUsedAt: Date?
    
    enum FieldKeys {
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

    public init() {}
    
    public init(
        id: UUID? = nil,
        name: String,
        identity: Identity,
        scopes: [String] = [],
        rateLimit: Int = 1000,
        validUntil: Date = Date().addingTimeInterval(365 * 24 * 3600)
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
        
        if appEnv == .development || appEnv == .testing {
            return withDependencies {
                $0.uuid = .incrementing
            } operation: {
                "\(prefix)test_\(UUID(0).uuidString)"
            }
        } else {
            let randomBytes = SymmetricKey(size: .bits256)
            return prefix + Data(randomBytes.withUnsafeBytes { Data($0) }).base64EncodedString()
        }
    }
}

extension ApiKey {
    public enum Migration {
        public struct Create: AsyncMigration {
            
            public var name: String = "Coenttb_Identity.ApiKey.Migration.Create"
            
            public func prepare(on database: Database) async throws {
                try await database.schema(ApiKey.schema)
                    .id()
                    .field(FieldKeys.name, .string, .required)
                    .field(FieldKeys.key, .string, .required)
                    .field(FieldKeys.scopes, .array(of: .string), .required)
                    .field(FieldKeys.identityId, .uuid, .required, .references(Identity.schema, "id", onDelete: .cascade))
                    .field(FieldKeys.isActive, .bool, .required)
                    .field(FieldKeys.rateLimit, .int, .required)
                    .field(FieldKeys.validUntil, .datetime, .required)
                    .field(FieldKeys.createdAt, .datetime)
                    .field(FieldKeys.lastUsedAt, .datetime)
                    .unique(on: FieldKeys.key)
                    .create()
            }

            public func revert(on database: Database) async throws {
                try await database.schema(ApiKey.schema).delete()
            }
            
            public init(){}
        }
    }
}
