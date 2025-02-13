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

import Coenttb_Server
import Coenttb_Web
import Fluent
import FluentKit
import Identity_Provider
@preconcurrency import Mailgun
import Vapor

extension Identity_Provider.Identity.Provider.Client.EmailChange {
    package static func live(
        database: Fluent.Database,
        logger: Logger,
        sendEmailChangeConfirmation: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress, _ token: String) async throws -> Void,
        sendEmailChangeRequestNotification: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress) async throws -> Void,
        onEmailChangeSuccess: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress) async throws -> Void
    ) -> Self {
        .init(
            request: { newEmail in
                do {

                    guard let newEmail
                    else {
                        throw ValidationError.invalidInput("Email address cannot be nil")
                    }

                    @Dependency(\.request) var request
                    guard let request else { throw Abort.requestUnavailable }
                    guard let token = request.cookies.reauthorizationToken?.string
                    else {
                        return .requiresReauthentication
                    }
                    do {
                        try await request.jwt.verify(
                            token,
                            as: JWT.Token.Reauthorization.self
                        )
                    } catch {
                        return .requiresReauthentication
                    }

                    let identity = try await Database.Identity.get(by: .auth, on: database)
                    try await database.transaction { db in

                        if try await Database.Identity.query(on: db)
                            .filter(\.$email == newEmail.rawValue)
                            .first() != nil {
                            throw ValidationError.invalidInput("Email address is already in use")
                        }
                        // Delete any existing email change tokens
                        do {
                            try await Database.Identity.Token.query(on: db)
                                .filter(\.$identity.$id == identity.id!)
                                .filter(\.$type == .emailChange)
                                .delete()
                        } catch {

                        }

                        // Generate and save new token
                        let changeToken = try identity.generateToken(
                            type: .emailChange,
                            validUntil: Date().addingTimeInterval(24 * 60 * 60)
                        )

                        try await changeToken.save(on: db)
                        // Create and save email change request
                        let emailChangeRequest = try Database.EmailChangeRequest(
                            identity: identity,
                            newEmail: newEmail,
                            token: changeToken
                        )
                        
                        try await emailChangeRequest.save(on: db)
                        
                        @Dependency(\.fireAndForget) var fireAndForget
                        
                        await fireAndForget {
                            try await sendEmailChangeConfirmation(
                                identity.emailAddress,
                                newEmail,
                                changeToken.value
                            )
                            
                            logger.notice("Emailchange confirmation-request for user: \(identity.email) to new email: \(newEmail)")
                        }
                        
                        await fireAndForget {
                            try await sendEmailChangeRequestNotification(
                                identity.emailAddress,
                                newEmail
                            )
                            
                            logger.notice("Emailchange notification for user: \(identity.email) to email: \(identity.emailAddress)")
                        }
                    }

                    return .success
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

                        @Dependency(\.fireAndForget) var fireAndForget
                        
                        await fireAndForget {
                            try await onEmailChangeSuccess(oldEmail, newEmail)
                        }
                        
                        return try await Identity.Authentication.Response(emailChangeRequest.identity)
                    }
                } catch {
                    logger.error("Error in confirmEmailChange: \(String(describing: error))")
                    throw error
                }
            }
        )
    }
}
