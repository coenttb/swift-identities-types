import Dependencies
import EmailAddress
import Foundation
import ServerFoundation

extension Identity.Client: TestDependencyKey {
    public static var testValue: Self {
        @Dependency(Identity.Client._TestDatabase.self) var database

        return Self(
            authenticate: .init(
                credentials: { username, password in
                    let session = try await database.authenticate(email: username, password: password)
                    return .init(
                        accessToken: session.accessToken,
                        refreshToken: session.refreshToken
                    )
                },
                token: .init(
                    access: { token in
                        try await database.validateAccessToken(token)
                    },
                    refresh: { token in
                        let session = try await database.refreshSession(token: token)
                        return .init(
                            accessToken: session.accessToken,
                            refreshToken: session.refreshToken
                        )
                    }
                ),
                apiKey: {
                    .init(
                        accessToken: $0,
                        refreshToken: $0
                    )
                }
            ),
            logout: .init(
                current: {
                    await database.reset()
                },
                all: {
                    await database.reset()
                }
            ),
            reauthorize: {
                return try .parse(from: $0)
            },
            create: .init(
                request: { email, password in
                    _ = try EmailAddress(email)
                    try await database.createUser(email: email, password: password)
                },
                verify: { email, token in
                    _ = try EmailAddress(email)
                    try await database.verifyUser(email: email, token: token)
                }
            ),
            delete: .init(
                request: { reauthToken in
                    guard case let email = "reauth-token",
                          !email.isEmpty else {
                        throw Identity.Client._TestDatabase.TestError.invalidToken
                    }
                    try await database.requestDeletion(email: email, reauthToken: reauthToken)
                },
                cancel: {

                    guard let email = await database.currentUser else {
                        throw Identity.Client._TestDatabase.TestError.userNotFound
                    }
                    try await database.cancelDeletion(email: email)
                },
                confirm: {

                    guard let email = await database.currentUser else {
                        throw Identity.Client._TestDatabase.TestError.userNotFound
                    }
                    try await database.confirmDeletion(email: email)
                }
            ),
            email: .init(
                change: .init(
                    request: { newEmail in
                        _ = try EmailAddress(newEmail)
                        guard let currentEmail = await database.currentUser else {
                            throw Identity.Client._TestDatabase.TestError.userNotFound
                        }
                        _ = try await database.initiateEmailChange(currentEmail: currentEmail, newEmail: newEmail)
                        return .success
                    },
                    confirm: { token in
                        guard let email = await database.currentUser else {
                            throw Identity.Client._TestDatabase.TestError.userNotFound
                        }
                        let session = try await database.confirmEmailChange(email: email, token: token)
                        
                        return .init(
                            accessToken: session.accessToken,
                            refreshToken: session.refreshToken
                        )
                    }
                )
            ),
            password: .init(
                reset: .init(
                    request: { email in
                        _ = try EmailAddress(email)
                        _ = try await database.initiatePasswordReset(email: email)
                    },
                    confirm: { newPassword, token in
                        try await database.confirmPasswordReset(token: token, newPassword: newPassword)
                    }
                ),
                change: .init(
                    request: { currentPassword, newPassword in
                        guard let email = await database.currentUser else {
                            throw Identity.Client._TestDatabase.TestError.userNotFound
                        }

                        try await database.changePassword(email: email, currentPassword: currentPassword, newPassword: newPassword)
                    }
                )
            ),
            mfa: nil  // MFA not configured in test implementation
        )
    }
}
