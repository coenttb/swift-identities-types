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

extension Coenttb_Identity.Client {
    public static func live<DatabaseUser: Fluent.Model>(
        database: Fluent.Database,
        logger: Logger,
        getDatabaseUser: (
            byUserId: (UUID) async throws -> DatabaseUser?,
            byIdentityId: (UUID) async throws -> DatabaseUser?
        ),
        userInit: @escaping (Identity, DatabaseUser) -> User,
        userUpdate: @escaping (_ newUser: User, _ identity: Identity, _ databaseUser: DatabaseUser) async throws -> Void,
        createDatabaseUser: @escaping (_ identityId: UUID) async throws -> DatabaseUser,
        currentUserId: @escaping () -> UUID?,
        currentUserEmail: @escaping () -> EmailAddress?,
        request: @escaping () -> Vapor.Request?,
        sendVerificationEmail: @escaping @Sendable (_ email: EmailAddress, _ token: String) async throws -> Void,
        authenticate: @escaping (any SessionAuthenticatable) throws -> Void,
        isAuthenticated: @escaping () throws -> Bool,
        logout: @escaping () throws -> Void,
        isValidEmail: @escaping (_ email: EmailAddress) throws -> Bool,
        isValidPassword: @escaping (_ password: String) throws -> Bool,
        sendPasswordResetEmail: @escaping @Sendable (_ email: EmailAddress, _ token: String) async throws -> Void,
        sendPasswordChangeNotification: @escaping @Sendable (_ email: EmailAddress) async throws -> Void,
        sendEmailChangeConfirmation: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress, _ token: String) async throws -> Void,
        sendEmailChangeRequestNotification: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress) async throws -> Void,
        onEmailChangeSuccess: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress) async throws -> Void
    ) -> Coenttb_Identity.Client<User> {
        
        return Coenttb_Identity.Client<User>(
            create: .init(
                request: {
                    email,
                    password in
                    do {
                        
                        guard try isValidEmail(email) else {
                            throw ValidationError.invalidInput("Invalid email format")
                        }
                        guard try isValidPassword(password) else {
                            throw ValidationError.invalidInput("Password does not meet requirements")
                        }
                        
                        try await database.transaction { database in
                            guard try await Identity
                                .query(on: database)
                                .filter(\.$email == email.rawValue)
                                .first() == nil
                            else { throw ValidationError.invalidInput("Email already in use") }
                            let identity = try Identity(email: email.rawValue, password: password)
                            try await identity.save(on: database)
                            
                            guard try await identity.canGenerateToken(on: database)
                            else { throw Abort(.tooManyRequests, reason: "Token generation limit exceeded") }
                            
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
                verify: { token, email in
                    do {
                        
                        guard let identityToken = try await Identity.Token.query(on: database)
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
                        
                    } catch {
                        throw Abort(.internalServerError, reason: "Verification failed: \(error.localizedDescription)")
                    }
                }
            ),
            delete: .init(
                request: { userId, reauthToken in
//                    guard let user = try await getDatabaseUser.byUserId(userId)
//                    else { throw Abort(.notFound, reason: "User not found") }
                    
//                    guard user.deletionState == nil else {
//                        throw Abort(.badRequest, reason: "User is already pending deletion")
//                    }
//                    
//                    user.deletionState = .pending
//                    user.deletionRequestedAt = Date()
//                    
//                    try await user.save(on: database)
                },
                cancel: { userId in
                    fatalError()
                    //                    guard let user = try await getDatabaseUser.byUserId(userId)
                    //                    else {
                    //                        throw Abort(.notFound, reason: "User not found")
                    //                    }
                    //
                    //                    guard
                    //                        let deletionstate = DeletionState.query(on: database)
                    //                            .filter(\.$identity.$id == currentUserId)
                    //                            .with(\.$identity)
                    //                            .first(),
                    //                        deletions
                    //                    else { throw Abort(.badRequest, reason: "User is not pending deletion") }
                    //
                    //
                    //                    user.deletionState = nil
                    //                    try await user.save(on: database)
                },
                confirm: { userId in
                    fatalError()
                    
                    //                    guard let user = try await getDatabaseUser.byUserId(userId)
                    //                    else {
                    //                        throw Abort(.notFound, reason: "User not found")
                    //                    }
                    //
                    //                    guard
                    //                        user.deletionState == .pending,
                    //                        let deletionRequestedAt = user.deletionRequestedAt
                    //                    else { throw Abort(.badRequest, reason: "User is not pending deletion") }
                    //
                    //                    let currentTime = Date()
                    //                    let gracePeriodDuration: TimeInterval = 7 * 24 * 60 * 60
                    //                    guard currentTime.timeIntervalSince(deletionRequestedAt) >= gracePeriodDuration else {
                    //                        throw Abort(.badRequest, reason: "Grace period has not yet expired")
                    //                    }
                    //
                    //
                    //                    user.deletionState = .deleted
                    //                    try await user.save(on: database)
                    
                    
                    
                },
                anonymize: { _ in
                    fatalError()
                }
            ),
            login: { email, password in
                do {
                    logger.log(.info, "Login attempt for email: \(email)")
                    guard let identity = try await Identity.query(on: database)
                        .filter(\.$email == email.rawValue)
                        .first()
                    else {
                        logger.log(.warning, "Identity not found for email: \(email)")
                        throw Abort(.notFound, reason: "Invalid email or password")
                    }
                    
                    guard try identity.verifyPassword(password) else {
                        throw AuthenticationError.invalidCredentials
                    }
                    
                    logger.log(.info, "Password verified for email: \(email)")
                    guard identity.emailVerificationStatus == .verified else {
                        logger.log(.warning, "Email not verified for: \(email)")
                        throw AuthenticationError.emailNotVerified
                    }
                    
                    logger.log(.info, "Email verified for: \(email)")
                    try authenticate(identity)
                    
                    @Dependency(\.request) var request
                    request?.session.data[Identity.FieldKeys.sessionVersion.description] = "\(identity.sessionVersion)"
                    logger.log(.notice, "Login successful for email: \(email)")
                } catch {
                    logger.log(.error, "Login error for email \(email): \(error)")
                    throw error  // Re-throw the error to be handled by the caller
                }
            },
            currentUser: {
                let request = request()
                guard let request else { throw Abort.requestUnavailable }
                
                guard let identity = request.auth.get(Identity.self)
                else { return nil }
                
                guard let identityId = identity.id else {
                    throw Abort(.internalServerError, reason: "Identity ID is unavailable")
                }
                
                guard let user = try await getDatabaseUser.byIdentityId(identityId)
                else { throw Abort(.notFound, reason: "User not found") }
                
                //                return ServerModels.User(identity, user: user)
                return userInit(identity, user)
            },
            update: { (update: User?) -> User? in
                guard let update else { return nil }
                
                guard let (identity, user) = try await Self.identityAndUser(getDatabaseUserByIdentityId: getDatabaseUser.byIdentityId)
                else { throw Abort(.internalServerError, reason: "Couldn't find Identity AND User")}
                
                try await userUpdate(update, identity, user)
                
                try await identity.save(on: database)
                try await user.save(on: database)
                
                return userInit(identity, user)
                
            },
            logout: {
                try logout()
            },
            password: .init(
                reset: .init(
                    request: { email in
                        do {
                            guard try isValidEmail(email) else {
                                throw ValidationError.invalidInput("Invalid email format")
                            }
                            
                            guard let identity = try await Identity.query(on: database)
                                .filter(\.$email == email.rawValue)
                                .first() else {
                                logger.log(.warning, "Password reset requested for non-existent email: \(email)")
                                return
                            }
                            
                            let expirationDate = Date().addingTimeInterval(3600)
                            
                            let resetToken = try identity.generateToken(type: .passwordReset, validUntil: expirationDate)
                            
                            try await database.transaction { database in
                                try await resetToken.save(on: database)
                                try await sendPasswordResetEmail(email, resetToken.value)
                            }
                            
                            logger.log(.notice, "Password reset email sent to: \(email)")
                        } catch {
                            logger.log(.error, "Error in requestPasswordReset: \(String(describing: error))")
                            throw error
                        }
                    },
                    confirm: { token, newPassword in
                        do {
                            guard try isValidPassword(newPassword) else {
                                throw ValidationError.invalidInput("New password does not meet requirements")
                            }
                            
                            guard let resetToken = try await Identity.Token.query(on: database)
                                .filter(\.$value == token)
                                .filter(\.$type == .passwordReset)
                                .with(\.$identity)
                                .first() else {
                                throw ValidationError.invalidToken
                            }
                            
                            guard resetToken.validUntil > Date() else {
                                try await resetToken.delete(on: database)
                                throw Abort(.gone, reason: "Reset token has expired")
                            }
                            
                            try resetToken.identity.setPassword(newPassword)
                            resetToken.identity.sessionVersion += 1
                            
                            try await database.transaction { database in
                                logger.log(.info, "Starting password reset transaction for email: \(resetToken.identity.email)")
                                try await resetToken.identity.save(on: database)
                                logger.log(.info, "New password hash saved for email: \(resetToken.identity.email)")
                                try await resetToken.delete(on: database)
                                logger.log(.info, "Reset token deleted for email: \(resetToken.identity.email)")
                            }
                            
                            logger.log(.notice, "Password reset transaction completed successfully for email: \(resetToken.identity.email)")
                            
                            logger.log(.notice, "Password reset successful for email: \(resetToken.identity.email)")
                        } catch {
                            logger.log(.error, "Error in resetPassword: \(String(describing: error))")
                            throw error
                        }
                    }
                ),
                change: .init(
                    request: { currentPassword, newPassword in
                        do {
                            guard let currentUserEmail = currentUserEmail() else {
                                fatalError()
                            }
                            
                            guard let identity = try await Identity.query(on: database)
                                .filter(\.$email == currentUserEmail.rawValue)
                                .first()
                            else {
                                throw Abort(.notFound, reason: "User not found")
                            }
                            
                            guard try identity.verifyPassword(currentPassword) else {
                                throw AuthenticationError.invalidCredentials
                            }
                            
                            guard try isValidPassword(newPassword) else {
                                throw ValidationError.invalidInput("New password does not meet requirements")
                            }
                            
                            try await database.transaction { database in
                                try identity.setPassword(newPassword)
                                identity.sessionVersion += 1
                                try await identity.save(on: database)
                                
                                try await sendPasswordChangeNotification(.init(identity.email))
                            }
                            
                            logger.notice("Password changed successfully for user: \(identity.email)")
                        } catch {
                            logger.error("Error in password change: \(error)")
                            throw error
                        }
                    }
                )
            ),
            emailChange: .init(
                request: { newEmail in
//                    logger.log(.info, "newEmail: \(newEmail ?? "nil")")
                    
                    do {
                        guard
                            let currentEmail = currentUserEmail(),
                            let currentUserId = currentUserId()
                                
                        else { throw Coenttb_Identity.Client<User>.RequestEmailChangeError.unauthorized }
                        
                        guard let reauthenticationToken = try await Identity.Token.query(on: database)
                            .filter(\.$identity.$id == currentUserId)
                            .filter(\.$type == .reauthenticationToken)
                            .filter(\.$validUntil > Date())
                            .first()
                        else { throw Coenttb_Identity.Client<User>.RequestEmailChangeError.unauthorized }
                        
                        guard let newEmail
                        else { throw Coenttb_Identity.Client<User>.RequestEmailChangeError.emailIsNil }
                        
                        guard try isValidEmail(newEmail)
                        else { throw ValidationError.invalidInput("Invalid new email format") }
                        
                        guard try await Identity.query(on: database)
                            .filter(\.$email == newEmail.rawValue)
                            .first() == nil
                        else {
                            logger.log(.info, "new email: \(newEmail)")
                            throw ValidationError.invalidInput("New email is already in use")
                        }
                        
                        guard let identity = try await Identity.query(on: database)
                            .filter(\.$email == currentEmail.rawValue)
                            .first()
                        else { throw Abort(.notFound, reason: "Current user identity not found") }
                        
                        let expirationDate = Date().addingTimeInterval(24 * 60 * 60)
                        
                        try await database.transaction { database in
                            let token = try identity.generateToken(type: .emailChange, validUntil: expirationDate)
                            try await token.save(on: database)
                            let emailChangeRequest = try EmailChangeRequest(
                                identity: identity,
                                newEmail: newEmail.rawValue,
                                token: token
                            )
                            
                            async let saveRequest: () = emailChangeRequest.save(on: database)
                            async let sendConfirmation: () = sendEmailChangeConfirmation(currentEmail, newEmail, token.value)
                            async let sendNotification: () = sendEmailChangeRequestNotification(currentEmail, newEmail)
                            
                            try await saveRequest
                            try await reauthenticationToken.delete(on: database)
                            try await sendConfirmation
                            try await sendNotification
                        }
                        
                        logger.log(.notice, "Email change requested for user: \(currentEmail) to new email: \(newEmail)")
                    } catch {
                        logger.log(.error, "Error in requestEmailChange: \(String(describing: error))")
                        throw error
                    }
                },
                confirm: { token in
                    do {
                        guard let token = try await Identity.Token.query(on: database)
                            .filter(\.$value == token)
                            .filter(\.$type == .emailChange)
                            .first()
                        else {
                            throw ValidationError.invalidToken
                        }
                        
                        guard let emailChangeRequest = try await EmailChangeRequest.query(on: database)
                            .filter(\.$token.$id == token.id!)
                            .with(\.$identity)
                            .first() else {
                            throw Abort(.notFound, reason: "Email change request not found")
                        }
                        
                        guard let currentEmail = currentUserEmail()
                        else {
                            throw Abort(.gone, reason: "No current email")
                        }
                        
                        let newEmail = emailChangeRequest.newEmail
                        
                        guard token.isValid else {
                            try await token.delete(on: database)
                            try await emailChangeRequest.delete(on: database)
                            throw Abort(.gone, reason: "Email change token has expired")
                        }
                        
                        
                        let oldEmail = emailChangeRequest.identity.email
                        emailChangeRequest.identity.email = newEmail
                        
                        emailChangeRequest.identity.sessionVersion += 1
                        
                        try await database.transaction { database in
                            try await emailChangeRequest.identity.save(on: database)
                            try await token.delete(on: database)
                            try await emailChangeRequest.delete(on: database)
                            try await onEmailChangeSuccess(
                                currentEmail,
                                .init(newEmail)
                            )
                        }
                        
                        logger.log(.notice, "Email change completed successfully from \(oldEmail) to \(newEmail)")
                    } catch {
                        logger.log(.error, "Error in confirmEmailChange: \(String(describing: error))")
                        throw error
                    }
                }
            )
        )
    }
}

extension Coenttb_Identity.Client {
    static func identityAndUser<DatabaseUser: Fluent.Model>(
        getDatabaseUserByIdentityId: (UUID) async throws -> DatabaseUser?
    ) async throws -> (Identity, DatabaseUser)? {
        @Dependency(\.request) var request
        guard let request else { throw Abort.requestUnavailable }
        
        guard let identity = request.auth.get(Identity.self) else {
            return nil
        }
        
        guard let identityId = identity.id else {
            throw Abort(.internalServerError, reason: "Identity ID is unavailable")
        }
        
        
        //        guard let user = try await DatabaseUser.query(on: request.db)
        //            .filter(\.$identity.$id == identityId)
        //            .first()
        guard let user = try await getDatabaseUserByIdentityId(identityId)
        else { throw Abort(.notFound, reason: "User not found") }
        
        return (identity, user)
    }
}

public enum ValidationError: Error {
    case invalidInput(String)
    case invalidToken
}

public enum AuthenticationError: Error {
    case invalidCredentials
    case emailNotVerified
}


