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

extension Identity_Provider.Identity.Provider.Client {
    public static func live<DatabaseUser: Fluent.Model & Sendable>(
        database: Fluent.Database,
        logger: Logger,
        createDatabaseUser: @escaping @Sendable (_ identityId: UUID) async throws -> DatabaseUser,
        getDatabaseUserbyIdentityId: @escaping @Sendable (UUID) async throws -> DatabaseUser?,
        userInit: @escaping @Sendable (Identity, DatabaseUser) -> User,
        userUpdate: @escaping @Sendable (_ newUser: User, _ identity: Identity, _ databaseUser: DatabaseUser) async throws -> Void,
        sendVerificationEmail: @escaping @Sendable (_ email: EmailAddress, _ token: String) async throws -> Void,
        sendPasswordResetEmail: @escaping @Sendable (_ email: EmailAddress, _ token: String) async throws -> Void,
        sendPasswordChangeNotification: @escaping @Sendable (_ email: EmailAddress) async throws -> Void,
        sendEmailChangeConfirmation: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress, _ token: String) async throws -> Void,
        sendEmailChangeRequestNotification: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress) async throws -> Void,
        sendDeletionRequestNotification: @escaping @Sendable (_ email: EmailAddress) async throws -> Void,
        sendDeletionConfirmationNotification: @escaping @Sendable (_ email: EmailAddress) async throws -> Void,
        onEmailChangeSuccess: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress) async throws -> Void,
        userDeletionState: ReferenceWritableKeyPath<DatabaseUser, DeletionState.DeletionState?>,
        userDeletionRequestedAt: ReferenceWritableKeyPath<DatabaseUser, Date?>
//        multifactorAuthentication: (
//            sendSMSCode: @Sendable (String, String) async throws -> Void,
//            sendEmailCode: @Sendable (EmailAddress, String) async throws -> Void,
//            generateTOTPSecret: @Sendable () -> String
//        )?
    ) -> Self {
        return Identity_Provider.Identity.Provider.Client(
            create: .live(
                database: database,
                logger: logger,
                createDatabaseUser: createDatabaseUser,
                sendVerificationEmail: sendVerificationEmail
            ),
            delete: .live(
                database: database,
                logger: logger,
                getDatabaseUserbyIdentityId: getDatabaseUserbyIdentityId,
                sendDeletionRequestNotification: sendDeletionRequestNotification,
                sendDeletionConfirmationNotification: sendDeletionConfirmationNotification,
                userDeletionState: userDeletionState,
                userDeletionRequestedAt: userDeletionRequestedAt
            ),
            login: { email, password in
                try await database.transaction { db in
                    logger.log(.info, "Login attempt for email: \(email)")
                    
                    guard let identity = try await Identity.query(on: db)
                        .filter(\.$email == email.rawValue)
                        .first()
                    else {
                        logger.log(.warning, "Identity not found for email: \(email)")
                        throw Abort(.notFound, reason: "Invalid email or password")
                    }
                    
                    guard try identity.verifyPassword(password) else {
                        throw AuthenticationError.invalidCredentials
                    }
                    
                    guard identity.emailVerificationStatus == .verified else {
                        logger.log(.warning, "Email not verified for: \(email)")
                        throw AuthenticationError.emailNotVerified
                    }
                    
                    @Dependency(\.request) var request
                    guard let request else { throw Abort.requestUnavailable }
                    
                    request.auth.login(identity)
                    request.session.authenticate(identity)
                    request.session.identityVersion = identity.sessionVersion
                    
                    // Update last login timestamp
                    identity.lastLoginAt = Date()
                    try await identity.save(on: db)
                    
                    logger.notice("Login successful for email: \(email)")
                }
            },
            currentUser: {
                try await database.transaction { db in
                    let identity = try await Identity.get(by: .auth, on: db)
                    
                    guard
                        let id = identity.id,
                        let user = try await getDatabaseUserbyIdentityId(id) else {
                        throw Abort(.notFound, reason: "User not found")
                    }
                    
                    return userInit(identity, user)
                }
            },
            update: { (update: User?) -> User? in
                guard let update else { return nil }
                
                return try await database.transaction { db in
                    @Dependency(\.request) var request
                    guard let request else { throw Abort.requestUnavailable }
                    
                    guard let identity = request.auth.get(Identity.self) else {
                        throw Abort(.unauthorized, reason: "Not authenticated")
                    }
                    guard let identityId = identity.id else {
                        throw Abort(.internalServerError, reason: "Invalid identity state")
                    }
                    
                    let freshIdentity = try await Identity.get(by: .id(identityId), on: db)
                    guard let user = try await getDatabaseUserbyIdentityId(identityId) else {
                        throw Abort(.notFound, reason: "User not found")
                    }
                    
                    try await userUpdate(update, freshIdentity, user)
                    
                    try await freshIdentity.save(on: db)
                    try await user.save(on: db)
                    
                    return userInit(freshIdentity, user)
                }
            },
            logout: {
                @Dependency(\.request) var request
                request?.auth.logout(Identity.self)
            },
            password: .live(
                database: database,
                logger: logger,
                sendPasswordResetEmail: sendPasswordResetEmail,
                sendPasswordChangeNotification: sendPasswordChangeNotification
            ),
            emailChange: .live(
                database: database,
                logger: logger,
                sendEmailChangeConfirmation: sendEmailChangeConfirmation,
                sendEmailChangeRequestNotification: sendEmailChangeRequestNotification,
                onEmailChangeSuccess: onEmailChangeSuccess
            )
//            multifactorAuthentication: multifactorAuthentication.map { mfa in
//                    .live(
//                        database: database,
//                        logger: logger,
//                        sendSMSCode: mfa.sendSMSCode,
//                        sendEmailCode: mfa.sendEmailCode,
//                        generateTOTPSecret: mfa.generateTOTPSecret
//                    )
//            }
        )
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

private struct PasswordValidation {
    static func validate(_ password: String) -> ValidationError? {
        // Minimum length check
        guard password.count >= 8 else {
            return .tooShort
        }
        
        // Check for at least one uppercase letter
        guard password.contains(where: { $0.isUppercase }) else {
            return .missingUppercase
        }
        
        // Check for at least one lowercase letter
        guard password.contains(where: { $0.isLowercase }) else {
            return .missingLowercase
        }
        
        // Check for at least one number
        guard password.contains(where: { $0.isNumber }) else {
            return .missingNumber
        }
        
        // Check for at least one special character
        let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")
        guard password.rangeOfCharacter(from: specialCharacters) != nil else {
            return .missingSpecialCharacter
        }
        
        return nil
    }
    
    enum ValidationError: String, Error {
        case tooShort = "Password must be at least 8 characters long"
        case missingUppercase = "Password must contain at least one uppercase letter"
        case missingLowercase = "Password must contain at least one lowercase letter"
        case missingNumber = "Password must contain at least one number"
        case missingSpecialCharacter = "Password must contain at least one special character"
    }
}

@Sendable func validatePassword(_ password: String) throws {
    if let error = PasswordValidation.validate(password) {
        throw Abort(.badRequest, reason: error.rawValue)
    }
}
