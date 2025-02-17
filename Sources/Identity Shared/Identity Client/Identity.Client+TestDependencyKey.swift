import Dependencies
import EmailAddress
import Foundation

extension Identity.Client: TestDependencyKey {
    public static var testValue: Identity.Client {
        .init(
            authenticate: .testValue,
            logout: { },
            reauthorize: { _ in
                return .init(value: "", expiresIn: 0)
            },
            create: .testValue,
            delete: .testValue,
            emailChange: .testValue,
            password: .testValue
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
                guard email.contains("@") else {
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
                _ = try EmailAddress(email)
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
                    _ = try EmailAddress(email)
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
            request: { _ in
                //                guard let email = newEmail else {
                //                    throw ValidationError.emailRequired
                //                }

                return .success

            },
            confirm: { token in
                fatalError()
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
            request: { reauthToken in
                guard !reauthToken.isEmpty else {
                    throw ValidationError.missingToken
                }
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
            credentials: { _, _ in
                    .init(
                        accessToken: .init(value: "test-access-token", expiresIn: 3600),
                        refreshToken: .init(value: "test-refresh-token", expiresIn: 86400)
                    )
            },
            token: .init(
                access: { token in
                    guard !token.isEmpty else {
                        throw ValidationError.invalidToken
                    }
                },
                refresh: { token in
                    guard !token.isEmpty else {
                        throw ValidationError.invalidToken
                    }
                    return .init(
                        accessToken: .init(value: "refreshed-access-token", expiresIn: 3600),
                        refreshToken: .init(value: "refreshed-refresh-token", expiresIn: 86400)
                    )
                }
            ),
            apiKey: { apiKey in
                guard !apiKey.isEmpty else {
                    throw ValidationError.invalidApiKey
                }
                return .init(
                    accessToken: .init(value: "apikey-access-token", expiresIn: 3600),
                    refreshToken: .init(value: "apikey-refresh-token", expiresIn: 86400)
                )
            }
        )
    }

    enum ValidationError: Error {
        case invalidEmail
        case invalidPassword
        case invalidToken
        case invalidApiKey
    }
}

