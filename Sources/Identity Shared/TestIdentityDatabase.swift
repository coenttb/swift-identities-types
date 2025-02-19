//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 19/02/2025.
//

import Foundation

import Dependencies
import EmailAddress
import Foundation

extension Identity.Client {
    package actor TestDatabase {
        private var users: [String: User] = [:]
        private var sessions: [String: Session] = [:]
        private var pendingVerifications: [String: PendingVerification] = [:]
        private var pendingDeletions: Set<String> = []
        
        public init(){}
        
        struct User {
            let email: String
            var password: String
            var isVerified: Bool
            var resetToken: String?
            var emailChangeToken: String?
            var newEmailPending: String?
        }
        
        struct Session {
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
        
        // MARK: - User Management
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
        
        func verifyUser(email: String, token: String) throws {
            guard let verification = pendingVerifications[token],
                  verification.email == email else {
                throw TestError.invalidVerificationToken
            }
            users[email]?.isVerified = true
            pendingVerifications.removeValue(forKey: token)
        }
        
        // MARK: - Authentication
        func authenticate(email: String, password: String) throws -> Session {
            guard let user = users[email],
                  user.password == password,
                  user.isVerified else {
                throw TestError.invalidCredentials
            }
            return createSession(for: email)
        }
        
        func refreshSession(token: String) throws -> Session {
            guard let session = sessions.first(where: { $0.value.refreshToken == token }) else {
                throw TestError.invalidToken
            }
            return createSession(for: session.value.userId)
        }
        
        // MARK: - Password Management
        func initiatePasswordReset(email: String) throws -> String {
            guard users[email] != nil else {
                throw TestError.userNotFound
            }
            let resetToken = UUID().uuidString
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
        
        // MARK: - Email Management
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
        
        // MARK: - Helper Methods
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
    enum TestError: Swift.Error {
        case emailAlreadyExists
        case invalidVerificationToken
        case invalidCredentials
        case invalidToken
        case userNotFound
        case invalidResetToken
    }
}

