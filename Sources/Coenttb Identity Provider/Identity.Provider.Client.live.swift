//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 12/09/2024.
//

import Coenttb_Vapor
import Dependencies
import Fluent
import Identities
import JWT

extension Identity.Provider.Client {
    public static func live(
        sendVerificationEmail: @escaping @Sendable (_ email: EmailAddress, _ token: String) async throws -> Void,
        sendPasswordResetEmail: @escaping @Sendable (_ email: EmailAddress, _ token: String) async throws -> Void,
        sendPasswordChangeNotification: @escaping @Sendable (_ email: EmailAddress) async throws -> Void,
        sendEmailChangeConfirmation: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress, _ token: String) async throws -> Void,
        sendEmailChangeRequestNotification: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress) async throws -> Void,
        onEmailChangeSuccess: @escaping @Sendable (_ currentEmail: EmailAddress, _ newEmail: EmailAddress) async throws -> Void,
        sendDeletionRequestNotification: @escaping @Sendable (_ email: EmailAddress) async throws -> Void,
        sendDeletionConfirmationNotification: @escaping @Sendable (_ email: EmailAddress) async throws -> Void,
        onIdentityCreationSuccess: @escaping @Sendable (_ identity: (id: UUID, email: EmailAddress)) async throws -> Void = { _ in }
    ) -> Self {
        @Dependency(\.logger) var logger
        @Dependency(\.database) var database
        
        return .init(
            authenticate: .live(),
            logout: {
                @Dependency(\.request) var request
                guard let request else { throw Abort.requestUnavailable }
                
                let identity = try await Database.Identity.get(by: .auth, on: request.db)
                identity.sessionVersion += 1
                try await identity.save(on: request.db)
                
                request.auth.logout(Database.Identity.self)
            },
            reauthorize: { password in
                do {
                    let identity = try await Database.Identity.get(by: .auth)
                    
                    guard try identity.verifyPassword(password)
                    else { throw AuthenticationError.invalidCredentials }
                    
                    let payload = try JWT.Token.Reauthorization.init(identity: identity)
                    
                    @Dependency(\.application) var application
                    
                    return try await .init(
                        value: application.jwt.keys.sign(payload)
                    )
                    
                } catch {
                    throw error
                }
            },
            create: .live(
                sendVerificationEmail: sendVerificationEmail,
                onIdentityCreationSuccess: onIdentityCreationSuccess
            ),
            delete: .live(
                sendDeletionRequestNotification: sendDeletionRequestNotification,
                sendDeletionConfirmationNotification: sendDeletionConfirmationNotification
            ),
            email: .live(
                sendEmailChangeConfirmation: sendEmailChangeConfirmation,
                sendEmailChangeRequestNotification: sendEmailChangeRequestNotification,
                onEmailChangeSuccess: onEmailChangeSuccess
            ),
            password: .live(
                sendPasswordResetEmail: sendPasswordResetEmail,
                sendPasswordChangeNotification: sendPasswordChangeNotification
            )
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
        guard password.count >= 8
        else { return .tooShort }
        
        // Check for at least one uppercase letter
        guard password.contains(where: { $0.isUppercase })
        else { return .missingUppercase }
        
        // Check for at least one lowercase letter
        guard password.contains(where: { $0.isLowercase })
        else { return .missingLowercase }
        
        // Check for at least one number
        guard password.contains(where: { $0.isNumber })
        else { return .missingNumber }
        
        // Check for at least one special character
        let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")
        
        guard password.rangeOfCharacter(from: specialCharacters) != nil
        else { return .missingSpecialCharacter }
        
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
