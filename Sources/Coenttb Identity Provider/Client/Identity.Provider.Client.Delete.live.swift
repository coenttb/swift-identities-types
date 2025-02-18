//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 01/02/2025.
//

import Coenttb_Server
import Fluent
import Identity_Provider
import Vapor

extension Identity_Provider.Identity.Provider.Client.Delete {
    package static func live(
        database: Fluent.Database,
        sendDeletionRequestNotification: @escaping @Sendable (_ email: EmailAddress) async throws -> Void,
        sendDeletionConfirmationNotification: @escaping @Sendable (_ email: EmailAddress) async throws -> Void
    ) -> Self {
        @Dependency(\.logger) var logger
        
        return .init(
            request: { reauthToken in
                let identity = try await Database.Identity.get(by: .auth, on: database)

                try await database.transaction { db in

                    guard
                        let id = identity.id,
                        let token = try await Database.Identity.Token.query(on: db)
                        .filter(\.$identity.$id == id)
                        .filter(\.$type == .reauthenticationToken)
                        .filter(\.$value == reauthToken)
                        .filter(\.$validUntil > Date())
                        .first()
                    else { throw Abort(.unauthorized, reason: "Invalid reauthorization token") }

                    try await token.delete(on: db)

                    guard identity.deletion?.state == nil else {
                        throw Abort(.badRequest, reason: "User is already pending deletion")
                    }

                    let deletion: Database.Identity.Deletion = try .init(identity: identity)

                    deletion.state = .pending
                    deletion.requestedAt = Date()
                    try await deletion.save(on: db)
                    logger.notice("Deletion requested for user \(String(describing: identity.id))")

                    @Dependency(\.fireAndForget) var fireAndForget
                    await fireAndForget {
                        try await sendDeletionRequestNotification(identity.emailAddress)
                    }
                    
                }
            },
            cancel: {
                let identity = try await Database.Identity.get(by: .auth, on: database)

                try await database.transaction { db in

                    guard identity.deletion?.state == .pending else {
                        throw Abort(.badRequest, reason: "User is not pending deletion")
                    }

                    identity.deletion?.state = nil
                    identity.deletion?.requestedAt = nil

                    try await identity.save(on: db)
                    logger.notice("Deletion cancelled for user \(String(describing: identity.id))")
                }
            },
            confirm: {
                let identity = try await Database.Identity.get(by: .auth, on: database)

                try await database.transaction { db in
                    guard
                        let deletion = identity.deletion,
                        deletion.state == .pending,
                        let deletionRequestedAt = deletion.requestedAt
                    else {
                        throw Abort(.badRequest, reason: "User is not pending deletion")
                    }

                    // Check grace period
                    let gracePeriod: TimeInterval = 7 * 24 * 60 * 60 // 7 days
                    guard Date().timeIntervalSince(deletionRequestedAt) >= gracePeriod else {
                        throw Abort(.badRequest, reason: "Grace period has not yet expired")
                    }

                    // Update user state
                    identity.deletion?.state = .deleted
                    try await identity.save(on: db)

                    // Send confirmation and log
                    
                    @Dependency(\.fireAndForget) var fireAndForget
                    await fireAndForget {
                        try await sendDeletionConfirmationNotification(identity.emailAddress)                     
                    }
                    
                    logger.notice("Identity \(String(describing: identity.id)) marked as deleted")
                }
            }
        )
    }
}
