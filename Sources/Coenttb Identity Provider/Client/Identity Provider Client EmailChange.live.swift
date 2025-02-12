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
    package static func live(
        database: Fluent.Database,
        logger: Logger,
        sendEmailChangeConfirmation: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress, _ token: String) async throws -> Void,
        sendEmailChangeRequestNotification: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress) async throws -> Void,
        onEmailChangeSuccess: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress) async throws -> Void
    ) -> Self  {
        .init(
            request: { newEmail in
                do {
                    
                    print("EmailChange Request 1")
                    guard let newEmail
                    else {
                        print("EmailChange Request 2")
                        throw ValidationError.invalidInput("Email address cannot be nil")
                    }
                    print("EmailChange Request 3")
                    
                    @Dependency(\.request) var request
                    guard let request else { throw Abort.requestUnavailable }
                    print("EmailChange Request 4")
                    guard let token = request.cookies.reauthorizationToken?.string
                    else {
                        print("EmailChange Request 5")
                        return .requiresReauthentication
                    }
                    print("EmailChange Request 6")
                    do {
                        try await request.jwt.verify(
                            token,
                            as: JWT.Token.Reauthorization.self
                        )
                    }
                    catch {
                        print("EmailChange Request 7")
                        return .requiresReauthentication
                    }
                    
                    let identity = try await Database.Identity.get(by: .auth, on: database)
                    print("EmailChange Request 8")
                    try await database.transaction { db in
                        
                        if try await Database.Identity.query(on: db)
                            .filter(\.$email == newEmail.rawValue)
                            .first() != nil {
                            throw ValidationError.invalidInput("Email address is already in use")
                        }
                        print("EmailChange Request 9")
                        // Delete any existing email change tokens
                        try await Database.Identity.Token.query(on: db)
                            .filter(\.$identity.$id == identity.id!)
                            .filter(\.$type == .emailChange)
                            .delete()
                        print("EmailChange Request 10")
                        // Generate and save new token
                        let changeToken = try identity.generateToken(
                            type: .emailChange,
                            validUntil: Date().addingTimeInterval(24 * 60 * 60)
                        )
                        
                        print("EmailChange Request 11")
                        try await changeToken.save(on: db)
                        print("EmailChange Request 12")
                        // Create and save email change request
                        let emailChangeRequest = try Database.EmailChangeRequest(
                            identity: identity,
                            newEmail: newEmail.rawValue,
                            token: changeToken
                        )
                        print("EmailChange Request 13")
                        // Execute all operations concurrently within transaction
                        try await emailChangeRequest.save(on: db)
                        print("EmailChange Request 14")
                        // Send notifications after database changes succeed
                        try await sendEmailChangeConfirmation(
                            identity.emailAddress,
                            newEmail,
                            changeToken.value
                        )
                        print("EmailChange Request 15")
                        try await sendEmailChangeRequestNotification(
                            identity.emailAddress,
                            newEmail
                        )
                        print("EmailChange Request 16")
                        logger.notice("Email change requested for user: \(identity.email) to new email: \(newEmail)")

                    }
                    
                    return .success
                }
                catch {
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
