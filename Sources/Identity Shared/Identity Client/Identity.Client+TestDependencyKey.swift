import Dependencies
import EmailAddress
import Foundation

// MARK: - Client Test Implementation
extension Identity.Client: TestDependencyKey {
    package static let database: Identity.Client.TestDatabase = .init()
    
    public static var testValue: Self {
        
        return Self(
            authenticate: .init(
                credentials: { username, password in
                    let session = try await Self.database.authenticate(email: username, password: password)
                    return .init(
                        accessToken: .init(value: session.accessToken, expiresIn: 3600),
                        refreshToken: .init(value: session.refreshToken, expiresIn: 86400)
                    )
                },
                token: .init(
                    access: { token in
                        // Validate access token exists
                    },
                    refresh: { token in
                        let session = try await Self.database.refreshSession(token: token)
                        return .init(
                            accessToken: .init(value: session.accessToken, expiresIn: 3600),
                            refreshToken: .init(value: session.refreshToken, expiresIn: 86400)
                        )
                    }
                ),
                apiKey: { apiKey in
                    // Simulate API key authentication
                    return .init(
                        accessToken: .init(value: UUID().uuidString, expiresIn: 3600),
                        refreshToken: .init(value: UUID().uuidString, expiresIn: 86400)
                    )
                }
            ),
            logout: {
                // Simulate logout by invalidating session
            },
            reauthorize: { password in
                // Simulate reauthorization
                return .init(value: UUID().uuidString, expiresIn: 3600)
            },
            create: .init(
                request: { email, password in
                    _ = try EmailAddress(email) // Validate email format
                    try await Self.database.createUser(email: email, password: password)
                },
                verify: { email, token in
                    _ = try EmailAddress(email) // Validate email format
                    try await Self.database.verifyUser(email: email, token: token)
                }
            ),
            delete: .init(
                request: { reauthToken in
                    // Validate reauth token and mark for deletion
                },
                cancel: {
                    // Remove deletion mark
                },
                confirm: {
                    // Permanently delete user
                }
            ),
            email: .init(
                change: .init(
                    request: { newEmail in
                        _ = try EmailAddress(newEmail) // Validate email format
                        return .success
                    },
                    confirm: { token in
                        // Confirm email change
                        return .init(
                            accessToken: .init(value: UUID().uuidString, expiresIn: 3600),
                            refreshToken: .init(value: UUID().uuidString, expiresIn: 86400)
                        )
                    }
                )
            ),
            password: .init(
                reset: .init(
                    request: { email in
                        _ = try EmailAddress(email) // Validate email format
                        _ = try await Self.database.initiatePasswordReset(email: email)
                    },
                    confirm: { newPassword, token in
                        try await Self.database.confirmPasswordReset(token: token, newPassword: newPassword)
                    }
                ),
                change: .init(
                    request: { currentPassword, newPassword in
                        // Validate current password and update to new password
                    }
                )
            )
        )
    }
}
