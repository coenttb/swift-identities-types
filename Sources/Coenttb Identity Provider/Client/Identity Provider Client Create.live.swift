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

extension Identity_Provider.Identity.Provider.Client.Create {
    package static func live<DatabaseUser: Fluent.Model & Sendable>(
        database: Fluent.Database,
        logger: Logger,
        createDatabaseUser: @escaping @Sendable (_ identityId: UUID) async throws -> DatabaseUser,
        sendVerificationEmail: @escaping @Sendable (_ email: EmailAddress, _ token: String) async throws -> Void
    ) -> Self  {
        .init(
            request: { email, password in
                do {
                    try validatePassword(password)
                    
                    try await database.transaction { database in
                        guard try await Database.Identity
                            .query(on: database)
                            .filter(\.$email == email.rawValue)
                            .first() == nil
                        else { throw ValidationError.invalidInput("Email already in use") }
                        
                        let identity = try Database.Identity(email: email, password: password)
                        try await identity.save(on: database)
                        
                        // Claude: Delete any existing verification tokens for this identity
                        try await Database.Identity.Token.query(on: database)
                            .filter(\.$identity.$id == identity.id!)
                            .filter(\.$type == .emailVerification)
                            .delete()
                        
                        guard try await identity.canGenerateToken(on: database)
                        else { throw Abort(.tooManyRequests, reason: "Token generation limit exceeded") }
                        
                        // Delete existing verification tokens first
                        try await Database.Identity.Token.query(on: database)
                            .filter(\.$identity.$id == identity.id!)
                            .filter(\.$type == .emailVerification)
                            .delete()
                        
                        let verificationToken = try identity.generateToken(type: .emailVerification)
                        
                        try await verificationToken.save(on: database)
                        try await sendVerificationEmail(email, verificationToken.value)
                    }
                    
                    logger.log(.notice, "User created successfully and verification email sent")
                } catch {
                    logger.log(.error, "Error in create: \(String(describing: error))")
                    throw error
                }
            },
            verify: { email, token in
                do {
                    try await database.transaction { db in
                        guard let identityToken = try await Database.Identity.Token.query(on: db)
                            .filter(\.$value == token)
                            .with(\.$identity)
                            .first() else {
                            throw Abort(.notFound, reason: "Invalid or expired token")
                        }
                        
                        guard identityToken.validUntil > Date.now else {
                            try await identityToken.delete(on: database)
                            throw Abort(.gone, reason: "Token has expired")
                        }
                        
                        guard identityToken.identity.email == email.rawValue else {
                            throw Abort(.badRequest, reason: "Email mismatch")
                        }
                        
                        identityToken.identity.emailVerificationStatus = .verified
                        
                        guard let identityId = identityToken.identity.id else {
                            throw Abort(.internalServerError, reason: "identity has no id")
                        }
                        
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
