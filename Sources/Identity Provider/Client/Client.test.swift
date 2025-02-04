import Foundation
import Dependencies
import EmailAddress

extension Identity.Provider.Client: TestDependencyKey {
    public static var testValue: Identity.Provider.Client {
        .init(
            create: .testValue,
            delete: .testValue,
            login: { email, password in
                guard password.count >= 8 else {
                    throw ValidationError.invalidCredentials
                }
            },
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
    
    enum ValidationError: Error {
        case invalidCredentials
    }
}

extension Identity.Provider.Client.Create: TestDependencyKey {
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
            verify: { token, email in
                guard !token.isEmpty else {
                    throw ValidationError.invalidToken
                }
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
        case weakPassword
        case invalidToken
    }
}

extension Identity.Provider.Client.Password: TestDependencyKey {
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
    
    public static var previewValue: Self {
        return testValue
    }
    
    enum ValidationError: Error {
        case invalidEmail
        case weakPassword
        case samePassword
        case invalidToken
    }
}

extension Identity.Provider.Client.EmailChange: TestDependencyKey {
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
                
                return try! .init("test@example.com")
            }
        )
    }
    
    public static var previewValue: Self {
        return testValue
    }
    
    enum ValidationError: Error {
        case emailRequired
        case invalidEmail
        case invalidToken
    }
}

extension Identity.Provider.Client.Delete: TestDependencyKey {
    public static var testValue: Self {
        .init(
            request: { /*userId,*/ reauthToken in
                guard !reauthToken.isEmpty else {
                    throw ValidationError.missingToken
                }
            },
            cancel: { /*userId in*/
//                guard !String(userId).isEmpty else {
//                    throw ValidationError.invalidUserId
//                }
            },
            confirm: { /*userId in*/
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
