
import Foundation
import Dependencies
import EmailAddress

// MARK: - Main Client Test Implementation
extension Identity.Consumer.Client: TestDependencyKey {
    public static var testValue: Identity.Consumer.Client {
        .init(
            create: .testValue,
            delete: .testValue,
            authenticate: .testValue,
//            currentUser: {
//                return nil
//            },
//            update: { user in
//                return user
//            },
            logout: { },
            password: .testValue,
            emailChange: .testValue
        )
    }
    
    public static var previewValue: Self {
        return testValue
    }
}

// MARK: - Create Client Test Implementation
extension Identity.Consumer.Client.Create: TestDependencyKey {
    public static var testValue: Self {
        .init(
            request: { email, password in
                // Validate email format
                guard email.rawValue.contains("@") else {
                    throw ValidationError.invalidEmail
                }
                // Validate password length
                guard password.count >= 8 else {
                    throw ValidationError.weakPassword
                }
            },
            verify: { email, token in
                // Validate token
                guard !token.isEmpty else {
                    throw ValidationError.tokenRequired
                }
                guard token.count >= 32 else {
                    throw ValidationError.invalidToken
                }
                // Validate email format
                guard email.rawValue.contains("@") else {
                    throw ValidationError.invalidEmail
                }
            }
        )
    }
    
    public static var previewValue: Self {
        return testValue
    }
    
    enum ValidationError: Error {
        case invalidEmail
        case invalidToken
        case tokenRequired
        case weakPassword
    }
}

// MARK: - Password Client Test Implementation
extension Identity.Consumer.Client.Password: TestDependencyKey {
    public static var testValue: Self {
        .init(
            reset: .init(
                request: { email in
                    // Basic email validation
                    guard email.rawValue.contains("@") else {
                        throw ValidationError.invalidEmail
                    }
                },
                confirm: { newPassword, token in
                    // Validate token
                    guard !token.isEmpty else {
                        throw ValidationError.tokenRequired
                    }
                    guard token.count >= 32 else {
                        throw ValidationError.invalidToken
                    }
                    // Validate new password
                    guard newPassword.count >= 8 else {
                        throw ValidationError.weakPassword
                    }
                }
            ),
            change: .init(
                request: { currentPassword, newPassword in
                    // Validate password requirements
                    guard newPassword.count >= 8 else {
                        throw ValidationError.weakPassword
                    }
                    guard currentPassword != newPassword else {
                        throw ValidationError.samePassword
                    }
                }
            )
        )
    }
    
    public static var previewValue: Self {
        return testValue
    }
    
    enum ValidationError: Error {
        case invalidEmail
        case invalidToken
        case weakPassword
        case samePassword
        case tokenRequired
    }
}

// MARK: - EmailChange Client Test Implementation
extension Identity.Consumer.Client.EmailChange: TestDependencyKey {
    public static var testValue: Self {
        .init(
            request: { newEmail in
                // Validate new email
                guard let email = newEmail else {
                    throw ValidationError.emailRequired
                }
                guard email.rawValue.contains("@") else {
                    throw ValidationError.invalidEmail
                }
            },
            confirm: { token in
                guard !token.isEmpty else {
                    throw ValidationError.tokenRequired
                }
                guard token.count >= 32 else {
                    throw ValidationError.invalidToken
                }
            }
        )
    }
    
    public static var previewValue: Self {
        return testValue
    }
    
    enum ValidationError: Error {
        case emailRequired
        case invalidEmail
        case tokenRequired
        case invalidToken
    }
}

// MARK: - Delete Client Test Implementation
extension Identity.Consumer.Client.Delete: TestDependencyKey {
    public static var testValue: Self {
        .init(
            request: { /*userId,*/ reauthToken in
                // Validate reauth token
//                guard !reauthToken.isEmpty else {
//                    throw ValidationError.missingToken
//                }
            },
            cancel: { /*userId in*/
                // Provide cancellation implementation
//                guard !String(userId).isEmpty else {
//                    throw ValidationError.invalidUserId
//                }
            }
        )
    }
    
    public static var previewValue: Self {
        return testValue
    }
    
    enum ValidationError: Error {
        case missingToken
        case invalidUserId
    }
}


// MARK: - Authenticate Client Test Implementation
extension Identity.Consumer.Client.Authenticate: TestDependencyKey {
    public static var testValue: Self {
        .init(
            credentials: { credentials in
                    .init(token: "test", expiresIn: 10)
            },
            bearer: { token in
                    .init(token: "test", expiresIn: 10)
            }
        )
    }
    
    public static var previewValue: Self {
        return testValue
    }
    
    enum ValidationError: Error {
        case missingToken
        case invalidUserId
    }
}
