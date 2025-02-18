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

extension Identity_Provider.Identity.Provider.Client.Create {
    package static func live<DatabaseUser: Fluent.Model & Sendable>(
        database: Fluent.Database,
        createDatabaseUser: @escaping @Sendable (_ identityId: UUID) async throws -> DatabaseUser,
        sendVerificationEmail: @escaping @Sendable (_ email: EmailAddress, _ token: String) async throws -> Void
    ) -> Self {
        @Dependency(\.logger) var logger
        
        return .init(
            request: { email, password in
                do {
                    try validatePassword(password)
                    let email = try EmailAddress(email)
                                    
                    let verificationToken = try await database.transaction { database in
                        guard try await Database.Identity
                            .query(on: database)
                            .filter(\.$email == email.rawValue)
                            .first() == nil
                        else { throw ValidationError.invalidInput("Email already in use") }

                        let identity = try Database.Identity(email: email, password: password)
                        try await identity.save(on: database)

                        try await Database.Identity.Token.query(on: database)
                            .filter(\.$identity.$id == identity.id!)
                            .filter(\.$type == .emailVerification)
                            .delete()

                        guard try await identity.canGenerateToken(on: database)
                        else { throw Abort(.tooManyRequests, reason: "Token generation limit exceeded") }

                        try await Database.Identity.Token.query(on: database)
                            .filter(\.$identity.$id == identity.id!)
                            .filter(\.$type == .emailVerification)
                            .delete()

                        let verificationToken = try identity.generateToken(type: .emailVerification)

                        try await verificationToken.save(on: database)
                        return verificationToken.value
                    }
                    
                    @Dependency(\.fireAndForget) var fireAndForget
                    await fireAndForget {
                        try await sendVerificationEmail(email, verificationToken)
                    }

                    logger.log(.notice, "User created successfully and verification email sent")
                } catch {
                    logger.log(.error, "Error in create: \(String(describing: error))")
                    throw error
                }
            },
            verify: { email, token in
                do {
                    try await database.transaction { database in
                        guard let identityToken = try await Database.Identity.Token.query(on: database)
                            .filter(\.$value == token)
                            .with(\.$identity)
                            .first()
                        else { throw Abort(.notFound, reason: "Invalid or expired token") }

                        guard identityToken.validUntil > Date.now
                        else {
                            try await identityToken.delete(on: database)
                            throw Abort(.gone, reason: "Token has expired")
                        }
                        
                        let email = try EmailAddress(email)

                        guard identityToken.identity.email == email.rawValue
                        else { throw Abort(.badRequest, reason: "Email mismatch") }

                        identityToken.identity.emailVerificationStatus = .verified

                        guard let identityId = identityToken.identity.id
                        else { throw Abort(.internalServerError, reason: "identity has no id") }

                        try await identityToken.identity.save(on: database)

                        try await createDatabaseUser(identityId)
                            .save(on: database)

                        try await identityToken.delete(on: database)
                    }
                } catch {
                    throw Abort(.internalServerError, reason: "Verification failed: \(error.localizedDescription)")
                }
            }
        )
    }
}
