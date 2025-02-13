//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Coenttb_Identity_Shared
import Dependencies
@preconcurrency import Fluent
import Foundation
import Identity_Shared
@preconcurrency import Vapor

extension Database.MultifactorAuthentication {
    package final class Audit {
        package final class Event: Model, Content, @unchecked Sendable {
            package static let schema = "mfa_audit_events"

            @ID(key: .id)
            package var id: UUID?

            @Field(key: FieldKeys.userId)
            package var userId: String

            @Enum(key: FieldKeys.type)
            package var type: Identity.Authentication.Multifactor.Audit.Event.`Type`

            @OptionalEnum(key: FieldKeys.method)
            package var method: Identity.Authentication.Multifactor.Method?

            @Field(key: FieldKeys.timestamp)
            package var timestamp: Date

            @Field(key: FieldKeys.metadata)
            package var metadata: [String: String]

            package enum FieldKeys {
                package static let userId: FieldKey = "user_id"
                package static let type: FieldKey = "type"
                package static let method: FieldKey = "method"
                package static let timestamp: FieldKey = "timestamp"
                package static let metadata: FieldKey = "metadata"
            }

            package init() {}

            package init(
                id: UUID? = nil,
                userId: String,
                eventType: Identity.Authentication.Multifactor.Audit.Event.`Type`,
                method: Identity.Authentication.Multifactor.Method? = nil,
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

extension Database.MultifactorAuthentication.Audit.Event {
    package enum Migration {
        package struct Create: AsyncMigration {
            package var name: String = "Identity_Provider.MultifactorAuthentication.Audit.Event.Migration.Create"

            package init() {}

            package func prepare(on database: Fluent.Database) async throws {
                try await database.schema(Database.MultifactorAuthentication.Audit.Event.schema)
                    .id()
                    .field(FieldKeys.userId, .string, .required)
                    .field(FieldKeys.type, .string, .required)
                    .field(FieldKeys.method, .string)
                    .field(FieldKeys.timestamp, .datetime, .required)
                    .field(FieldKeys.metadata, .json, .required)
                    .create()
            }

            package func revert(on database: Fluent.Database) async throws {
                try await database.schema(Database.MultifactorAuthentication.Audit.Event.schema).delete()
            }
        }
    }
}

extension Identity.Authentication.Multifactor.Audit.Event {
    init(_ event: Database.MultifactorAuthentication.Audit.Event) {
        self.init(
            userId: event.userId,
            eventType: event.type,
            method: event.method,
            timestamp: event.timestamp,
            metadata: event.metadata
        )
    }
}
