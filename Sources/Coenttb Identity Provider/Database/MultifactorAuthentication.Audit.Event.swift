//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Dependencies
@preconcurrency import Fluent
import Foundation
@preconcurrency import Vapor
import Coenttb_Identity_Shared

extension MultifactorAuthentication {
    public final class Audit {
        public final class Event: Model, Content, @unchecked Sendable {
            public static let schema = "mfa_audit_events"

            @ID(key: .id)
            public var id: UUID?

            @Field(key: FieldKeys.userId)
            public var userId: String

            @Enum(key: FieldKeys.type)
            public var type: Identity_Shared.MultifactorAuthentication.Audit.Event.`Type`

            @OptionalEnum(key: FieldKeys.method)
            public var method: Identity_Shared.MultifactorAuthentication.Method?

            @Field(key: FieldKeys.timestamp)
            public var timestamp: Date

            @Field(key: FieldKeys.metadata)
            public var metadata: [String: String]

            public enum FieldKeys {
                public static let userId: FieldKey = "user_id"
                public static let type: FieldKey = "type"
                public static let method: FieldKey = "method"
                public static let timestamp: FieldKey = "timestamp"
                public static let metadata: FieldKey = "metadata"
            }

            public init() {}

            public init(
                id: UUID? = nil,
                userId: String,
                eventType: Identity_Shared.MultifactorAuthentication.Audit.Event.`Type`,
                method: Identity_Shared.MultifactorAuthentication.Method? = nil,
                timestamp: Date = .now,
                metadata: [String: String] = [:]
            ) {
                self.id = id
                self.userId = userId
                self.type = eventType
                self.method = method
                self.timestamp = timestamp
                self.metadata = metadata
            }
        }
    }
}

extension MultifactorAuthentication.Audit.Event {
    public enum Migration {
        public struct Create: AsyncMigration {
            public var name: String = "Identity_Provider.MultifactorAuthentication.Audit.Event.Migration.Create"
            
            public init() {}

            public func prepare(on database: Database) async throws {
                try await database.schema(MultifactorAuthentication.Audit.Event.schema)
                    .id()
                    .field(FieldKeys.userId, .string, .required)
                    .field(FieldKeys.type, .string, .required)
                    .field(FieldKeys.method, .string)
                    .field(FieldKeys.timestamp, .datetime, .required)
                    .field(FieldKeys.metadata, .json, .required)
                    .create()
            }

            public func revert(on database: Database) async throws {
                try await database.schema(MultifactorAuthentication.Audit.Event.schema).delete()
            }
        }
    }
}

extension Identity_Shared.MultifactorAuthentication.Audit.Event {
    init(_ event: MultifactorAuthentication.Audit.Event) {
        self.init(
            userId: event.userId,
            eventType: event.type,
            method: event.method,
            timestamp: event.timestamp,
            metadata: event.metadata
        )
    }
}
