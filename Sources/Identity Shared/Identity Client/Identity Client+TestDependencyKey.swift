import Foundation
import Dependencies
import EmailAddress

extension Identity.Client: TestDependencyKey {
    public static var testValue: Identity.Client {
        .init(
            authenticate: .testValue,
            create: .testValue,
            delete: .testValue,
            emailChange: .testValue,
            password: .testValue,
            multifactorAuthentication: nil
        )
    }
    
    enum ValidationError: Error {
        case invalidCredentials
    }
}

extension Identity.Client.Create: TestDependencyKey {
    public static var testValue: Self {
        .init(
            request: { email, password in
                guard email.rawValue.contains("@") else {
                    throw ValidationError.invalidEmail
                }
                guard password.count >= 8 else {
                    throw ValidationError.weakPassword
                }
            },
            verify: { email, token in
                guard !token.isEmpty else {
                    throw ValidationError.invalidToken
                }
                guard email.rawValue.contains("@") else {
                    throw ValidationError.invalidEmail
                }
            }
        )
    }
    
    enum ValidationError: Error {
        case invalidEmail
        case weakPassword
        case invalidToken
    }
}

extension Identity.Client.Password: TestDependencyKey {
    public static var testValue: Self {
        .init(
            reset: .init(
                request: { email in
                    guard email.rawValue.contains("@") else {
                        throw ValidationError.invalidEmail
                    }
                },
                confirm: { token, newPassword in
                    guard !token.isEmpty else {
                        throw ValidationError.invalidToken
                    }
                    guard newPassword.count >= 8 else {
                        throw ValidationError.weakPassword
                    }
                }
            ),
            change: .init(
                request: { currentPassword, newPassword in
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
    
    enum ValidationError: Error {
        case invalidEmail
        case weakPassword
        case samePassword
        case invalidToken
    }
}

extension Identity.Client.EmailChange: TestDependencyKey {
    public static var testValue: Self {
        .init(
            request: { newEmail in
                guard let email = newEmail else {
                    throw ValidationError.emailRequired
                }
                guard email.rawValue.contains("@") else {
                    throw ValidationError.invalidEmail
                }
            },
            confirm: { token in
                guard !token.isEmpty else {
                    throw ValidationError.invalidToken
                }
                
                //                return try! .init("test@example.com")
            }
        )
    }
    
    enum ValidationError: Error {
        case emailRequired
        case invalidEmail
        case invalidToken
    }
}

extension Identity.Client.Delete: TestDependencyKey {
    public static var testValue: Self {
        .init(
            request: { _ in
            },
            cancel: {
            },
            confirm: {
            }
        )
    }
    
    enum ValidationError: Error {
        case missingToken
        case invalidUserId
    }
}

extension Identity.Client.Authenticate: TestDependencyKey {
    public static var testValue: Self {
        .init(
            credentials: { credentials in
                fatalError()
            },
            token: .init(
                access: { token in
                    fatalError()
                },
                refresh: { token in
                    fatalError()
                }
            ),
            apiKey: { apiKey in
                fatalError()
            }
        )
    }
}
