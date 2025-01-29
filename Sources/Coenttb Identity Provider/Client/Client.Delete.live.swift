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
        getDatabaseUser: (
            byUserId: @Sendable (UUID) async throws -> DatabaseUser?,
            byIdentityId: @Sendable  (UUID) async throws -> DatabaseUser?
        ),
        sendDeletionRequestNotification: @escaping @Sendable (_ email: EmailAddress) async throws -> Void,
        sendDeletionConfirmationNotification: @escaping @Sendable (_ email: EmailAddress) async throws -> Void,
        userDeletionState: ReferenceWritableKeyPath<DatabaseUser, DeletionState.DeletionState?>,
        userDeletionRequestedAt: ReferenceWritableKeyPath<DatabaseUser, Date?>
    ) -> Self where User.ID == UUID {
        .init(
            request: {
                userId,
                reauthToken in
                try await database.transaction { db in
                    
                    guard let _ = try await Identity.Token.query(on: db)
                        .filter(\.$identity.$id == userId)
                        .filter(\.$type == .reauthenticationToken)
                        .filter(\.$value == reauthToken)
                        .filter(\.$validUntil > Date())
                        .first()
                    else { throw Abort(.unauthorized, reason: "Invalid reauthorization token") }
                    
                    guard let user = try await getDatabaseUser.byUserId(userId) else {
                        throw Abort(.notFound, reason: "User not found")
                    }
                    
                    guard user[keyPath: userDeletionState] == nil else {
                        throw Abort(.badRequest, reason: "User is already pending deletion")
                    }
                    
                    user[keyPath: userDeletionState] = .pending
                    user[keyPath: userDeletionRequestedAt] = Date()
                    
                    try await user.save(on: db)
                    logger.notice("Deletion requested for user \(userId)")
                    
                    guard let identity = try await Identity.query(on: db)
                        .filter(\.$id == userId)
                        .first(),
                          let email = try? EmailAddress(identity.email)
                    else { throw Abort(.badRequest, reason: "Identity not found or invalid email") }
                    
                    try await sendDeletionRequestNotification(email)
                    
                }
            },
            cancel: { userId in
                try await database.transaction { db in
                    guard let user = try await getDatabaseUser.byUserId(userId) else {
                        throw Abort(.notFound, reason: "User not found")
                    }
                    
                    guard user[keyPath: userDeletionState] == .pending else {
                        throw Abort(.badRequest, reason: "User is not pending deletion")
                    }
                    
                    user[keyPath: userDeletionState] = nil
                    user[keyPath: userDeletionRequestedAt] = nil
                    
                    try await user.save(on: db)
                    logger.notice("Deletion cancelled for user \(userId)")
                }
            },
            confirm: { userId in
                try await database.transaction { db in
                    // Get user and validate deletion state
                    guard let user = try await getDatabaseUser.byUserId(userId) else {
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
                    
                    // Get identity for email notification
                    guard let identity = try await Identity.query(on: db)
                        .filter(\.$id == userId)
                        .first(),
                          let email = try? EmailAddress(identity.email)
                    else {
                        throw Abort(.badRequest, reason: "Identity not found or invalid email")
                    }
                    
                    // Update user state
                    user[keyPath: userDeletionState] = .deleted
                    try await user.save(on: db)
                    
                    // Send confirmation and log
                    try await sendDeletionConfirmationNotification(email)
                    logger.notice("User \(userId) marked as deleted")
                }
            },
            anonymize: { userId in
                
            }
        )
    }
}
