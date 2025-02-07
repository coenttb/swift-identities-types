//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 16/10/2024.
//

//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 12/09/2024.
//

import Coenttb_Web
import Coenttb_Server
import Fluent
import Vapor
@preconcurrency import Mailgun
import Identity_Provider
import FluentKit

extension Identity_Provider.Identity.Provider.Client.EmailChange {
    public static func live(
        database: Fluent.Database,
        logger: Logger,
        sendEmailChangeConfirmation: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress, _ token: String) async throws -> Void,
        sendEmailChangeRequestNotification: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress) async throws -> Void,
        onEmailChangeSuccess: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress) async throws -> Void
    ) -> Self  {
        .init(
            request: { newEmail in
                do {
                    guard let newEmail else {
                        throw Identity.EmailChange.Request.Error.emailIsNil
                    }
                    
                    try await database.transaction { db in
                        
                        let identity = try await Database.Identity.get(by: .auth, on: db)
                        
                        guard let reauthToken = try await Database.Identity.Token.query(on: db)
                            .filter(\.$identity.$id == identity.id!)
                            .filter(\.$type == .reauthenticationToken)
                            .filter(\.$validUntil > Date())
                            .with(\.$identity)
                            .first()
                        else {
                            throw Identity.EmailChange.Request.Error.unauthorized
                        }
                        
                        if try await Database.Identity.query(on: db)
                            .filter(\.$email == newEmail.rawValue)
                            .first() != nil {
                            throw ValidationError.invalidInput("Email address is already in use")
                        }
                        
                        // Delete any existing email change tokens
                        try await Database.Identity.Token.query(on: db)
                            .filter(\.$identity.$id == identity.id!)
                            .filter(\.$type == .emailChange)
                            .delete()
                        
                        // Generate and save new token
                        let token = try identity.generateToken(
                            type: .emailChange,
                            validUntil: Date().addingTimeInterval(24 * 60 * 60)
                        )
                        try await token.save(on: db)
                        
                        // Create and save email change request
                        let emailChangeRequest = try Database.EmailChangeRequest(
                            identity: identity,
                            newEmail: newEmail.rawValue,
                            token: token
                        )
                        
                        // Execute all operations concurrently within transaction
                        try await emailChangeRequest.save(on: db)
                        try await reauthToken.delete(on: db)
                        
                        // Send notifications after database changes succeed
                        try await sendEmailChangeConfirmation(
                            identity.emailAddress,
                            newEmail,
                            token.value
                        )
                        try await sendEmailChangeRequestNotification(
                            identity.emailAddress,
                            newEmail
                        )
                        
                        logger.notice("Email change requested for user: \(identity.email) to new email: \(newEmail)")
                    }
                } catch {
                    logger.error("Error in requestEmailChange: \(String(describing: error))")
                    throw error
                }
            },
            confirm: { token in
                do {
                    return try await database.transaction { db in
                        // Re-fetch all entities within transaction for consistency
                        guard let token = try await Database.Identity.Token.query(on: db)
                            .filter(\.$value == token)
                            .filter(\.$type == .emailChange)
                            .with(\.$identity)
                            .first() else {
                            throw ValidationError.invalidToken
                        }
                        
                        guard let emailChangeRequest = try await Database.EmailChangeRequest.query(on: db)
                            .filter(\.$token.$id == token.id!)
                            .with(\.$identity)
                            .first() else {
                            throw Abort(.notFound, reason: "Email change request not found")
                        }
                        
                        guard token.validUntil > Date() else {
                            try await token.delete(on: db)
                            try await emailChangeRequest.delete(on: db)
                            throw Abort(.gone, reason: "Email change token has expired")
                        }
                        
                        let newEmail = try EmailAddress(emailChangeRequest.newEmail)
                        
                        // Check again for email uniqueness within transaction
                        if try await Database.Identity.query(on: db)
                            .filter(\.$email == newEmail.rawValue)
                            .filter(\.$id != emailChangeRequest.identity.id!)
                            .first() != nil {
                            throw ValidationError.invalidInput("Email address is already in use")
                        }
                        
                        let oldEmail = emailChangeRequest.identity.emailAddress
                        
                        // Update identity
                        emailChangeRequest.identity.emailAddress = newEmail
                        emailChangeRequest.identity.sessionVersion += 1
                        
                        // Save all changes
                        try await emailChangeRequest.identity.save(on: db)
                        try await token.delete(on: db)
                        try await emailChangeRequest.delete(on: db)
                        
                        logger.notice("Email change completed successfully from \(oldEmail) to \(newEmail)")
                        
                        // Trigger post-change callback after database changes succeed
                        try await onEmailChangeSuccess(oldEmail, newEmail)
                        
                    }
                } catch {
                    logger.error("Error in confirmEmailChange: \(String(describing: error))")
                    throw error
                }
            }
        )
    }
}
