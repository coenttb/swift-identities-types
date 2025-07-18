//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 12/09/2024.
//

import Coenttb_Server
import Fluent
import Identities
import Vapor

extension Identity.Provider.Client.Email {
    package static func live(
        sendEmailChangeConfirmation: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress, _ token: String) async throws -> Void,
        sendEmailChangeRequestNotification: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress) async throws -> Void,
        onEmailChangeSuccess: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress) async throws -> Void
    ) -> Self {
        @Dependency(\.database) var database
        @Dependency(\.logger) var logger

        return .init(
            change: .init(
                request: { newEmail in
                    do {
                        @Dependency(\.request) var request
                        guard let request else { throw Abort.requestUnavailable }
                        guard let token = request.headers.reauthorizationToken?.token
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

                        let newEmail = try EmailAddress(newEmail)

                        let changeToken = try await database.transaction { database in

                            if try await Database.Identity.query(on: database)
                                .filter(\.$email == newEmail.rawValue)
                                .first() != nil {
                                throw ValidationError.invalidInput("Email address is already in use")
                            }

                            do {
                                try await Database.Identity.Token.query(on: database)
                                    .filter(\.$identity.$id == identity.id!)
                                    .filter(\.$type == .emailChange)
                                    .delete()
                            } catch {

                            }

                            @Dependency(\.date) var date

                            let changeToken = try identity.generateToken(
                                type: .emailChange,
                                validUntil: date().addingTimeInterval(24 * 60 * 60)
                            )

                            try await changeToken.save(on: database)

                            let emailChangeRequest = try Database.EmailChangeRequest(
                                identity: identity,
                                newEmail: newEmail,
                                token: changeToken
                            )

                            try await emailChangeRequest.save(on: database)

                            return changeToken.value

                        }

                        @Dependency(\.fireAndForget) var fireAndForget

                        await fireAndForget {
                            try await sendEmailChangeConfirmation(
                                identity.emailAddress,
                                newEmail,
                                changeToken
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

                        return .success
                    } catch {
                        logger.error("Error in requestEmail.Change: \(String(describing: error))")
                        throw error
                    }
                },
                confirm: { token in
                    do {
                        let (response, oldEmail, newEmail) = try await database.transaction { database in
                            guard let token = try await Database.Identity.Token.query(on: database)
                                .filter(\.$value == token)
                                .filter(\.$type == .emailChange)
                                .with(\.$identity)
                                .first()
                            else { throw ValidationError.invalidToken }

                            guard let emailChangeRequest = try await Database.EmailChangeRequest.query(on: database)
                                .filter(\.$token.$id == token.id!)
                                .with(\.$identity)
                                .first()
                            else { throw Abort(.notFound, reason: "Email change request not found") }

                            @Dependency(\.date) var date

                            guard token.validUntil > date()
                            else {
                                try await token.delete(on: database)
                                try await emailChangeRequest.delete(on: database)
                                throw Abort(.gone, reason: "Email change token has expired")
                            }

                            let newEmail = try EmailAddress(emailChangeRequest.newEmail)

                            if try await Database.Identity.query(on: database)
                                .filter(\.$email == newEmail.rawValue)
                                .filter(\.$id != emailChangeRequest.identity.id!)
                                .first() != nil {
                                throw ValidationError.invalidInput("Email address is already in use")
                            }

                            let oldEmail = emailChangeRequest.identity.emailAddress

                            emailChangeRequest.identity.emailAddress = newEmail
                            emailChangeRequest.identity.sessionVersion += 1

                            try await emailChangeRequest.identity.save(on: database)

                            try await token.delete(on: database)

                            try await emailChangeRequest.delete(on: database)

                            logger.notice("Email change completed successfully from \(oldEmail) to \(newEmail)")

                            try await emailChangeRequest.identity.save(on: database)

                            try await token.delete(on: database)

                            try await emailChangeRequest.delete(on: database)

                            logger.notice("Email change completed successfully from \(oldEmail) to \(newEmail)")

                            return (
                                try await Identity.Authentication.Response(emailChangeRequest.identity),
                                oldEmail,
                                newEmail
                            )
                        }

                        @Dependency(\.fireAndForget) var fireAndForget
                        await fireAndForget {
                            do {
                                try await onEmailChangeSuccess(oldEmail, newEmail)
                            } catch {
                                logger.error("Failed to execute post-email change operations: \(error)")
                            }
                        }

                        return response
                    } catch {
                        logger.error("Error in confirmEmail.Change: \(String(describing: error))")
                        throw error
                    }
                }
            )
        )
    }
}
