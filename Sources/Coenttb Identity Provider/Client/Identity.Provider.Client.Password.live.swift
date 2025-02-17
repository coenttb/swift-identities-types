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

extension Identity_Provider.Identity.Provider.Client.Password {
    package static func live(
        database: Fluent.Database,
        sendPasswordResetEmail: @escaping @Sendable (_ email: EmailAddress, _ token: String) async throws -> Void,
        sendPasswordChangeNotification: @escaping @Sendable (_ email: EmailAddress) async throws -> Void
    ) -> Self {
        @Dependency(\.logger) var logger
        
        return .init(
            reset: .init(
                request: { email in
                    try await database.transaction { db in
                        guard let identity = try await Database.Identity.query(on: db)
                            .filter(\.$email == email.rawValue)
                            .first() else {
                            logger.warning("Password reset requested for non-existent email: \(email)")
                            return
                        }

                        guard let identityId = identity.id else {
                            throw Abort(.internalServerError, reason: "Invalid identity state")
                        }

                        // Delete existing reset tokens
                        try await Database.Identity.Token.query(on: db)
                            .filter(\.$identity.$id == identityId)
                            .filter(\.$type == .passwordReset)
                            .delete()

                        let resetToken = try identity.generateToken(
                            type: .passwordReset,
                            validUntil: Date().addingTimeInterval(3600)
                        )

                        try await resetToken.save(on: db)
                        try await sendPasswordResetEmail(email, resetToken.value)

                        logger.notice("Password reset email sent to: \(email)")
                    }
                },
                confirm: { token, newPassword in
                    do {
                        try validatePassword(newPassword)

                        try await database.transaction { db in
                            // Fetch and validate token within transaction for consistency
                            guard let resetToken = try await Database.Identity.Token.query(on: db)
                                .filter(\.$value == token)
                                .filter(\.$type == .passwordReset)
                                .with(\.$identity)
                                .first() else {
                                throw ValidationError.invalidToken
                            }

                            guard resetToken.validUntil > Date() else {
                                try await resetToken.delete(on: db)
                                throw Abort(.gone, reason: "Reset token has expired")
                            }

                            // Update password and session version
                            try resetToken.identity.setPassword(newPassword)
                            resetToken.identity.sessionVersion += 1

                            // Save changes and cleanup
                            try await resetToken.identity.save(on: db)
                            try await resetToken.delete(on: db)

                            // Send notification after changes are committed
                            try await sendPasswordChangeNotification(resetToken.identity.emailAddress)

                            logger.notice("Password reset successful for email: \(resetToken.identity.email)")
                        }
                    } catch {
                        logger.error("Error in resetPassword: \(String(describing: error))")
                        throw error
                    }
                }
            ),
            change: .init(
                request: { currentPassword, newPassword in

                    let identity = try await Database.Identity.get(by: .auth, on: database)

                    try await database.transaction { db in

                        guard try identity.verifyPassword(currentPassword)
                        else { throw AuthenticationError.invalidCredentials }

                        try validatePassword(newPassword)

                        try identity.setPassword(newPassword)

                        identity.sessionVersion += 1

                        try await identity.save(on: db)

                        try await sendPasswordChangeNotification(identity.emailAddress)

                        logger.notice("Password changed successfully for user: \(identity.email)")
                    }
                }
            )
        )
    }
}
