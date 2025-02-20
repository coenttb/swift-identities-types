//
//  File.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/02/2025.
//

import Foundation

import Dependencies
import EmailAddress
import Foundation

extension Identity.Client {
    /// An in-memory test database implementation for identity management operations.
    ///
    /// This actor provides a thread-safe test environment for identity operations while maintaining state.
    ///
    /// Example usage:
    /// ```swift
    /// let database = Identity.Client.TestDatabase()
    ///
    /// // Create a new user
    /// try await database.createUser(
    ///     email: "user@example.com",
    ///     password: "password123"
    /// )
    ///
    /// // Authenticate user
    /// let session = try await database.authenticate(
    ///     email: "user@example.com",
    ///     password: "password123"
    /// )
    ///
    package actor TestDatabase {
        private var users: [String: User] = [:]
        private var sessions: [String: Session] = [:]
        private var pendingVerifications: [String: PendingVerification] = [:]
        private var pendingDeletions: Set<String> = []
        
        public init(){}
        
        /// Represents a user account in the test database.
        struct User {
            let email: String
            var password: String
            var isVerified: Bool
            var resetToken: String?
            var emailChangeToken: String?
            var newEmailPending: String?
        }
        
        /// Represents an active authentication session.
        struct Session {
            let userId: String
            let accessToken: String
            let refreshToken: String
            let expiresAt: Date
        }
        /// Represents a pending email verification request.
        struct PendingVerification {
            let email: String
            let password: String
            let token: String
        }
        
        /// Creates a new user account.
        func createUser(email: String, password: String) throws {
            guard users[email] == nil else {
                throw TestError.emailAlreadyExists
            }
            users[email] = User(
                email: email,
                password: password,
                isVerified: false
            )
        }
        
        /// Verifies a user's email address.
        func verifyUser(email: String, token: String) throws {
            guard let verification = pendingVerifications[token],
                  verification.email == email else {
                throw TestError.invalidVerificationToken
            }
            users[email]?.isVerified = true
            pendingVerifications.removeValue(forKey: token)
        }
        
        /// Authenticates a user with email and password.
        func authenticate(email: String, password: String) throws -> Session {
            guard let user = users[email],
                  user.password == password,
                  user.isVerified else {
                throw TestError.invalidCredentials
            }
            return createSession(for: email)
        }
        
        /// Refreshes an authentication session.
        func refreshSession(token: String) throws -> Session {
            guard let session = sessions.first(where: { $0.value.refreshToken == token }) else {
                throw TestError.invalidToken
            }
            return createSession(for: session.value.userId)
        }
        
        /// Initiates a password reset request.
        func initiatePasswordReset(email: String) throws -> String {
            guard users[email] != nil else {
                throw TestError.userNotFound
            }
            let resetToken = UUID().uuidString
            users[email]?.resetToken = resetToken
            return resetToken
        }
        
        /// Confirms a password reset request.
        func confirmPasswordReset(token: String, newPassword: String) throws {
            guard let user = users.first(where: { $0.value.resetToken == token }) else {
                throw TestError.invalidResetToken
            }
            users[user.key]?.password = newPassword
            users[user.key]?.resetToken = nil
        }
        
        /// Initiates an email address change.
        func initiateEmailChange(currentEmail: String, newEmail: String) throws -> String {
            guard users[currentEmail] != nil else {
                throw TestError.userNotFound
            }
            guard users[newEmail] == nil else {
                throw TestError.emailAlreadyExists
            }
            let changeToken = UUID().uuidString
            users[currentEmail]?.emailChangeToken = changeToken
            users[currentEmail]?.newEmailPending = newEmail
            return changeToken
        }
        
        /// Creates a new authentication session.
        private func createSession(for userId: String) -> Session {
            let session = Session(
                userId: userId,
                accessToken: UUID().uuidString,
                refreshToken: UUID().uuidString,
                expiresAt: Date().addingTimeInterval(3600)
            )
            sessions[session.accessToken] = session
            return session
        }
    }
}


extension Identity.Client.TestDatabase {
    /// Error types that can occur during test database operations.
    enum TestError: Swift.Error {
        /// Indicates an attempt to create an account with an existing email
        case emailAlreadyExists
        /// Indicates an invalid or expired verification token
        case invalidVerificationToken
        /// Indicates incorrect email/password combination
        case invalidCredentials
        /// Indicates an invalid or expired authentication token
        case invalidToken
        /// Indicates an operation on a non-existent user
        case userNotFound
        /// Indicates an invalid or expired password reset token
        case invalidResetToken
    }
}

