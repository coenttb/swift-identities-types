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
import Coenttb_Vapor
@preconcurrency import Mailgun
import Identity_Provider
import FluentKit
import JWT

extension Identity_Provider.Identity.Provider.Client {
    public static func live<DatabaseUser: Fluent.Model & Sendable>(
        database: Fluent.Database,
        logger: Logger,
        issuer: String = ._coenttbIssuer,
        createDatabaseUser: @escaping @Sendable (_ identityId: UUID) async throws -> DatabaseUser,
        sendVerificationEmail: @escaping @Sendable (_ email: EmailAddress, _ token: String) async throws -> Void,
        sendPasswordResetEmail: @escaping @Sendable (_ email: EmailAddress, _ token: String) async throws -> Void,
        sendPasswordChangeNotification: @escaping @Sendable (_ email: EmailAddress) async throws -> Void,
        sendEmailChangeConfirmation: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress, _ token: String) async throws -> Void,
        sendEmailChangeRequestNotification: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress) async throws -> Void,
        onEmailChangeSuccess: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress) async throws -> Void,
        sendDeletionRequestNotification: @escaping @Sendable (_ email: EmailAddress) async throws -> Void,
        sendDeletionConfirmationNotification: @escaping @Sendable (_ email: EmailAddress) async throws -> Void
        //        multifactorAuthentication: (
        //            sendSMSCode: @Sendable (String, String) async throws -> Void,
        //            sendEmailCode: @Sendable (EmailAddress, String) async throws -> Void,
        //            generateTOTPSecret: @Sendable () -> String
        //        )?
    ) -> Self {
        
        return Identity.Provider.Client(
            authenticate: .live(
                database: database,
                logger: logger,
                issuer: issuer
            ),
            logout: {
                @Dependency(\.request) var request
                guard let request else { throw Abort.requestUnavailable }
                request.auth.logout(Database.Identity.self)
            },
            create: .live(
                database: database,
                logger: logger,
                createDatabaseUser: createDatabaseUser,
                sendVerificationEmail: sendVerificationEmail
            ),
            delete: .live(
                database: database,
                logger: logger,
                //                getDatabaseUserbyIdentityId: getDatabaseUserbyIdentityId,
                sendDeletionRequestNotification: sendDeletionRequestNotification,
                sendDeletionConfirmationNotification: sendDeletionConfirmationNotification
            ),
            emailChange: .live(
                database: database,
                logger: logger,
                sendEmailChangeConfirmation: sendEmailChangeConfirmation,
                sendEmailChangeRequestNotification: sendEmailChangeRequestNotification,
                onEmailChangeSuccess: onEmailChangeSuccess
            ),
            password: .live(
                database: database,
                logger: logger,
                sendPasswordResetEmail: sendPasswordResetEmail,
                sendPasswordChangeNotification: sendPasswordChangeNotification
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

enum AuthError: Error {
    case invalidKey
    case expiredKey
    case rateLimitExceeded
}

