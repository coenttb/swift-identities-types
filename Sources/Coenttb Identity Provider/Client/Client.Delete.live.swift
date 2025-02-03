//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 01/02/2025.
//

import Foundation
import Coenttb_Web
import Coenttb_Server
import Fluent
import Vapor
@preconcurrency import Mailgun
import Identity_Provider
import FluentKit

extension Identity_Provider.Identity.Provider.Client.Delete {
    public static func live<DatabaseUser: Fluent.Model & Sendable>(
        database: Fluent.Database,
        logger: Logger,
        getDatabaseUserbyIdentityId: @escaping @Sendable (UUID) async throws -> DatabaseUser?,
        sendDeletionRequestNotification: @escaping @Sendable (_ email: EmailAddress) async throws -> Void,
        sendDeletionConfirmationNotification: @escaping @Sendable (_ email: EmailAddress) async throws -> Void,
        userDeletionState: ReferenceWritableKeyPath<DatabaseUser, DeletionState.DeletionState?>,
        userDeletionRequestedAt: ReferenceWritableKeyPath<DatabaseUser, Date?>
    ) -> Self {
        .init(
            request: {
                reauthToken in
                try await database.transaction { db in
                    
                    let identity = try await Identity.get(by: .auth, on: db)
                    
                    guard
                        let id = identity.id,
                        let _ = try await Identity.Token.query(on: db)
                        .filter(\.$identity.$id == id)
                        .filter(\.$type == .reauthenticationToken)
                        .filter(\.$value == reauthToken)
                        .filter(\.$validUntil > Date())
                        .first()
                    else { throw Abort(.unauthorized, reason: "Invalid reauthorization token") }
                    
                    guard let user = try await getDatabaseUserbyIdentityId(id) else {
                        throw Abort(.notFound, reason: "User not found")
                    }
                    
                    guard user[keyPath: userDeletionState] == nil else {
                        throw Abort(.badRequest, reason: "User is already pending deletion")
                    }
                    
                    user[keyPath: userDeletionState] = .pending
                    user[keyPath: userDeletionRequestedAt] = Date()
                    
                    try await user.save(on: db)
                    logger.notice("Deletion requested for user \(String(describing: user.id))")
                    
                    
                    try await sendDeletionRequestNotification(identity.emailAddress)
                    
                }
            },
            cancel: {
                try await database.transaction { db in
                    
                    let identity = try await Identity.get(by: .auth, on: db)
                    
                    guard
                        let id = identity.id,
                        let user = try await getDatabaseUserbyIdentityId(id) else {
                        throw Abort(.notFound, reason: "User not found")
                    }
                    
                    guard user[keyPath: userDeletionState] == .pending else {
                        throw Abort(.badRequest, reason: "User is not pending deletion")
                    }
                    
                    user[keyPath: userDeletionState] = nil
                    user[keyPath: userDeletionRequestedAt] = nil
                    
                    try await user.save(on: db)
                    logger.notice("Deletion cancelled for user \(String(describing: user.id))")
                }
            },
            confirm: {
                try await database.transaction { db in
                    
                    let identity = try await Identity.get(by: .auth, on: db)
                    
                    // Get user and validate deletion state
                    guard
                        let id = identity.id,
                        let user = try await getDatabaseUserbyIdentityId(id) else {
                        throw Abort(.notFound, reason: "User not found")
                    }
                    
                    guard
                        user[keyPath: userDeletionState] == .pending,
                        let deletionRequestedAt = user[keyPath: userDeletionRequestedAt]
                    else {
                        throw Abort(.badRequest, reason: "User is not pending deletion")
                    }
                    
                    // Check grace period
                    let gracePeriod: TimeInterval = 7 * 24 * 60 * 60 // 7 days
                    guard Date().timeIntervalSince(deletionRequestedAt) >= gracePeriod else {
                        throw Abort(.badRequest, reason: "Grace period has not yet expired")
                    }
                    
                                       
                    // Update user state
                    user[keyPath: userDeletionState] = .deleted
                    try await user.save(on: db)
                    
                    // Send confirmation and log
                    try await sendDeletionConfirmationNotification(identity.emailAddress)
                    logger.notice("User \(String(describing: user.id)) marked as deleted")
                }
            }
        )
    }
}
