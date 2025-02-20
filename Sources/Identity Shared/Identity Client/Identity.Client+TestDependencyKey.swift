import Dependencies
import EmailAddress
import Foundation

import Dependencies
import EmailAddress
import Foundation

// MARK: - Client Test Implementation
extension Identity.Client: TestDependencyKey {
    public static var testValue: Self {
        @Dependency(Identity.Client.TestDatabase.self) var database
        
        return Self(
            authenticate: .init(
                credentials: { username, password in
                    let session = try await database.authenticate(email: username, password: password)
                    return .init(
                        accessToken: .init(value: session.accessToken, expiresIn: 3600),
                        refreshToken: .init(value: session.refreshToken, expiresIn: 86400)
                    )
                },
                token: .init(
                    access: { token in
                        try await database.validateAccessToken(token)
                    },
                    refresh: { token in
                        let session = try await database.refreshSession(token: token)
                        return .init(
                            accessToken: .init(value: session.accessToken, expiresIn: 3600),
                            refreshToken: .init(value: session.refreshToken, expiresIn: 86400)
                        )
                    }
                ),
                apiKey: { apiKey in
                    // For API key auth, we use consistent tokens for testing
                    return .init(
                        accessToken: .init(value: "api-access-token", expiresIn: 3600),
                        refreshToken: .init(value: "api-refresh-token", expiresIn: 86400)
                    )
                }
            ),
            logout: {
                await database.reset() // Clear all state on logout
            },
            reauthorize: { password in
                // Re-authenticate with current user's credentials
                return .init(value: "reauth-token", expiresIn: 3600)
            },
            create: .init(
                request: { email, password in
                    _ = try EmailAddress(email) // Validate email format
                    try await database.createUser(email: email, password: password)
                },
                verify: { email, token in
                    _ = try EmailAddress(email) // Validate email format
                    try await database.verifyUser(email: email, token: token)
                }
            ),
            delete: .init(
                request: { reauthToken in
                    guard case let email = "reauth-token", // Simple token validation for testing
                          !email.isEmpty else {
                        throw Identity.Client.TestDatabase.TestError.invalidToken
                    }
                    try await database.requestDeletion(email: email, reauthToken: reauthToken)
                },
                cancel: {
                    // Cancel deletion for current user
                    guard let email = await database.currentUser else {
                        throw Identity.Client.TestDatabase.TestError.userNotFound
                    }
                    try await database.cancelDeletion(email: email)
                },
                confirm: {
                    // Confirm deletion for current user
                    guard let email = await database.currentUser else {
                        throw Identity.Client.TestDatabase.TestError.userNotFound
                    }
                    try await database.confirmDeletion(email: email)
                }
            ),
            email: .init(
                change: .init(
                    request: { newEmail in
                        _ = try EmailAddress(newEmail) // Validate email format
                        guard let currentEmail = await database.currentUser else {
                            throw Identity.Client.TestDatabase.TestError.userNotFound
                        }
                        _ = try await database.initiateEmailChange(currentEmail: currentEmail, newEmail: newEmail)
                        return .success
                    },
                    confirm: { token in
                        guard let email = await database.currentUser else {
                            throw Identity.Client.TestDatabase.TestError.userNotFound
                        }
                        let session = try await database.confirmEmailChange(email: email, token: token)
                        return .init(
                            accessToken: .init(value: session.accessToken, expiresIn: 3600),
                            refreshToken: .init(value: session.refreshToken, expiresIn: 86400)
                        )
                    }
                )
            ),
            password: .init(
                reset: .init(
                    request: { email in
                        _ = try EmailAddress(email) // Validate email format
                        _ = try await database.initiatePasswordReset(email: email)
                    },
                    confirm: { newPassword, token in
                        try await database.confirmPasswordReset(token: token, newPassword: newPassword)
                    }
                ),
                change: .init(
                    request: { currentPassword, newPassword in
                        guard let email = await database.currentUser else {
                            throw Identity.Client.TestDatabase.TestError.userNotFound
                        }
                        // Update password directly since user is authenticated
                        try await database.changePassword(email: email, currentPassword: currentPassword, newPassword: newPassword)
                    }
                )
            )
        )
    }
}
