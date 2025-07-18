//
//  Identity.Client.TestDatabase.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/02/2025.
//

import Dependencies
import EmailAddress
import Foundation
extension Identity.Client {
    package actor TestDatabase {
        private var users: [String: User] = [:]
        package var sessions: [String: Session] = [:]
        private var pendingVerifications: [String: PendingVerification] = [:]
        private var pendingDeletions: Set<String> = []
        package var currentUser: String?

        public init() {}

        struct User {
            let email: String
            var password: String
            var isVerified: Bool
            var resetToken: String?
            var emailChangeToken: String?
            var newEmailPending: String?
        }

        package struct Session {
            let userId: String
            let accessToken: String
            let refreshToken: String
            let expiresAt: Date
        }

        struct PendingVerification {
            let email: String
            let password: String
            let token: String
        }

        public func reset() async {
            users.removeAll()
            sessions.removeAll()
            pendingVerifications.removeAll()
            pendingDeletions.removeAll()
            currentUser = nil
        }

        func createUser(email: String, password: String) throws {
            guard users[email] == nil else {
                throw TestError.emailAlreadyExists
            }

            users[email] = User(
                email: email,
                password: password,
                isVerified: false
            )

            let verificationToken = generateVerificationToken(for: email)
            pendingVerifications[verificationToken] = PendingVerification(
                email: email,
                password: password,
                token: verificationToken
            )
        }

        func verifyUser(email: String, token: String) throws {
            let expectedToken = generateVerificationToken(for: email)
            guard token == expectedToken,
                  var user = users[email] else {
                throw TestError.invalidVerificationToken
            }

            user.isVerified = true
            users[email] = user
            pendingVerifications.removeValue(forKey: token)
        }

        func authenticate(email: String, password: String) throws -> Session {
            guard let user = users[email],
                  user.password == password,
                  user.isVerified else {
                throw TestError.invalidCredentials
            }
            currentUser = email
            return createSession(for: email)
        }

        func refreshSession(token: String) throws -> Session {
            guard let _ = sessions.first(where: { $0.value.refreshToken == token }),
                  let email = currentUser else {
                throw TestError.invalidToken
            }
            return createSession(for: email)
        }

        func validateAccessToken(_ token: String) throws {
            guard sessions.first(where: { $0.value.accessToken == token }) != nil else {
                throw TestError.invalidToken
            }
        }

        func initiatePasswordReset(email: String) throws -> String {
            guard users[email] != nil else {
                throw TestError.userNotFound
            }

            let resetToken = generateResetToken(for: email)
            users[email]?.resetToken = resetToken
            return resetToken
        }

        func confirmPasswordReset(token: String, newPassword: String) throws {
            guard let user = users.first(where: { $0.value.resetToken == token }) else {
                throw TestError.invalidResetToken
            }

            users[user.key]?.password = newPassword
            users[user.key]?.resetToken = nil
        }

        func changePassword(email: String, currentPassword: String, newPassword: String) throws {
            // Verify current password
            guard let user = users[email],
                  user.password == currentPassword else {
                throw TestError.invalidCredentials
            }

            // Update password
            users[email]?.password = newPassword
        }

        func initiateEmailChange(currentEmail: String, newEmail: String) throws -> String {
            guard users[currentEmail] != nil else {
                throw TestError.userNotFound
            }
            guard users[newEmail] == nil else {
                throw TestError.emailAlreadyExists
            }

            let changeToken = generateEmailChangeToken(for: currentEmail)
            users[currentEmail]?.emailChangeToken = changeToken
            users[currentEmail]?.newEmailPending = newEmail
            return changeToken
        }

        func confirmEmailChange(email: String, token: String) throws -> Session {
            let expectedToken = generateEmailChangeToken(for: email)
            guard token == expectedToken,
                  let user = users[email],
                  let newEmail = user.newEmailPending else {
                throw TestError.invalidVerificationToken
            }

            // Remove old email
            users.removeValue(forKey: email)

            // Add user with new email
            users[newEmail] = User(
                email: newEmail,
                password: user.password,
                isVerified: true
            )

            currentUser = newEmail
            return createSession(for: newEmail)
        }

        func requestDeletion(email: String, reauthToken: String) throws {
            guard users[email] != nil else {
                throw TestError.userNotFound
            }
            pendingDeletions.insert(email)
        }

        func cancelDeletion(email: String) throws {
            guard users[email] != nil else {
                throw TestError.userNotFound
            }
            pendingDeletions.remove(email)
        }

        func confirmDeletion(email: String) throws {
            guard users[email] != nil,
                  pendingDeletions.contains(email) else {
                throw TestError.userNotFound
            }

            users.removeValue(forKey: email)
            pendingDeletions.remove(email)
            currentUser = nil

            // Remove any associated sessions
            sessions = sessions.filter { $0.value.userId != email }
        }

        private func createSession(for userId: String) -> Session {
            let session = Session(
                userId: userId,
                accessToken: generateAccessToken(for: userId),
                refreshToken: generateRefreshToken(for: userId),
                expiresAt: Date().addingTimeInterval(3600)
            )
            sessions[session.accessToken] = session
            return session
        }

        private func generateVerificationToken(for email: String) -> String {
            return "verification-token-\(email)"
        }

        private func generateResetToken(for email: String) -> String {
            return "reset-token-\(email)"
        }

        private func generateEmailChangeToken(for email: String) -> String {
            return "email-change-token-\(email)"
        }

        private func generateAccessToken(for userId: String) -> String {
            return "access-token-\(userId)"
        }

        private func generateRefreshToken(for userId: String) -> String {
            return "refresh-token-\(userId)"
        }
    }
}

extension Identity.Client.TestDatabase {
    enum TestError: Swift.Error {
        case emailAlreadyExists
        case invalidVerificationToken
        case invalidCredentials
        case invalidToken
        case userNotFound
        case invalidResetToken
    }
}

extension Identity.Client.TestDatabase: TestDependencyKey {
    package static var testValue: Identity.Client.TestDatabase = .init()
    package static var testValue2: Identity.Client.TestDatabase = .init()
}
