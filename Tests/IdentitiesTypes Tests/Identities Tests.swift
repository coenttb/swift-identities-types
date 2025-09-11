//
//  File.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import Dependencies
import DependenciesTestSupport
import EmailAddress
import Foundation
@testable import IdentitiesTypes
import Testing

@Suite(
    "Authentication Tests"
)
struct AuthenticationTests {
    @Test("Successfully authenticates with valid credentials")
    func testValidCredentialsAuthentication() async throws {
        try await Identity._TestDatabase.Helper.withIsolatedDatabase {

            @Dependency(\.identity) var identity

            let email = "auth@example.com"
            let password = "password123"

            try await identity.create.request(email: email, password: password)
            try await identity.create.verify(email: email, token: "verification-token-\(email)")

            let response = try await identity.login(username: email, password: password)
            
            #expect(response.accessToken.isEmpty == false)
            #expect(response.refreshToken.isEmpty == false)
        }
    }

    @Test("Fails authentication with invalid credentials")
    func testInvalidCredentialsAuthentication() async throws {
        try await Identity._TestDatabase.Helper.withIsolatedDatabase {

            @Dependency(\.identity) var identity

            await #expect(throws: Identity._TestDatabase.TestError.invalidCredentials) {
                try await identity.login(username: "nonexistent@example.com", password: "wrongpass")
            }

        }
    }

    @Test("Successfully authenticates with API key")
    func testApiKeyAuthentication() async throws {
        try await Identity._TestDatabase.Helper.withIsolatedDatabase {

            @Dependency(\.identity) var identity

            let apiKey = "valid-api-key"
            let response = try await identity.login(apiKey: apiKey)

            // Test implementation returns the API key as both tokens
            #expect(response.accessToken == apiKey)
            #expect(response.refreshToken == apiKey)

        }
    }

    @Test("Successfully refreshes token")
    func testTokenRefresh() async throws {
        try await Identity._TestDatabase.Helper.withIsolatedDatabase {

            @Dependency(\.identity) var identity

            let email = "refresh@example.com"
            let password = "password123"

            try await identity.create.request(email: email, password: password)
            try await identity.create.verify(email: email, token: "verification-token-\(email)")
            let initialResponse = try await identity.authenticate.credentials(username: email, password: password)

            // Refresh token
            _ = try await identity.authenticate.token.refresh(initialResponse.refreshToken)
        }
    }
}

@Suite(
    "Identity Creation Tests"
)
struct IdentityCreationTests {
    @Test("Successfully creates new identity")
    func testIdentityCreation() async throws {
        try await Identity._TestDatabase.Helper.withIsolatedDatabase {

            @Dependency(\.identity) var identity

            let email = "new@example.com"
            let password = "securePass123"

            try await identity.create.request(email: email, password: password)
            try await identity.create.verify(email: email, token: "verification-token-\(email)")

            let response = try await identity.login(username: email, password: password)
            #expect(response.accessToken.isEmpty == false)

        }
    }

    @Test("Fails verification with invalid token")
    func testInvalidVerificationToken() async throws {
        try await Identity._TestDatabase.Helper.withIsolatedDatabase {

            @Dependency(\.identity) var identity

            let email = "invalid@example.com"

            try await identity.create.request(email: email, password: "password123")

            await #expect(throws: Identity._TestDatabase.TestError.invalidVerificationToken) {
                try await identity.create.verify(email: email, token: "wrong-token")
            }

        }
    }

    @Test("Prevents duplicate email registration")
    func testDuplicateEmailPrevention() async throws {
        try await Identity._TestDatabase.Helper.withIsolatedDatabase {

            @Dependency(\.identity) var identity

            let email = "duplicate@example.com"

            try await identity.create.request(email: email, password: "password123")

            await #expect(throws: Identity._TestDatabase.TestError.emailAlreadyExists) {
                try await identity.create.request(email: email, password: "anotherpass")
            }
        }
    }
}

@Suite(
    "Password Management Tests"
)
struct PasswordManagementTests {
    @Test("Successfully completes password reset flow")
    func testPasswordResetFlow() async throws {
        try await Identity._TestDatabase.Helper.withIsolatedDatabase {

            @Dependency(\.identity) var identity

            let email = "reset@example.com"
            let initialPassword = "initial123"
            let newPassword = "newPass123"

            // Setup: Create and verify user
            try await identity.create.client.request(email: email, password: initialPassword)
            try await identity.create.client.verify(email: email, token: "verification-token-\(email)")

            // Request and confirm reset
            try await identity.password.reset.request(email: email)
            try await identity.password.reset.confirm(newPassword: newPassword, token: "reset-token-\(email)")

            // Verify new password works
            let response = try await identity.login(username: email, password: newPassword)
            #expect(response.accessToken.isEmpty == false)

            // Verify old password doesn't work
            await #expect(throws: Identity._TestDatabase.TestError.invalidCredentials) {
                _ = try await identity.login(username: email, password: initialPassword)
            }

        }
    }

    @Test("Successfully changes password for authenticated user")
    func testPasswordChange() async throws {
        try await Identity._TestDatabase.Helper.withIsolatedDatabase {

            @Dependency(\.identity) var identity

            let email = "change@example.com"
            let currentPassword = "current123"
            let newPassword = "new123"

            // Setup: Create, verify, and login user
            try await identity.create.client.request(email: email, password: currentPassword)
            try await identity.create.client.verify(email: email, token: "verification-token-\(email)")
            _ = try await identity.login(username: email, password: currentPassword)

            // Change password
            try await identity.password.change.request(
                currentPassword: currentPassword,
                newPassword: newPassword
            )

            // Verify new password works
            let response = try await identity.login(username: email, password: newPassword)
            #expect(response.accessToken.isEmpty == false)

            // Verify old password doesn't work
            await #expect(throws: Identity._TestDatabase.TestError.invalidCredentials) {
                _ = try await identity.login(username: email, password: currentPassword)
            }
        }
    }

    @Test("Fails password reset with invalid token")
    func testInvalidResetToken() async throws {
        try await Identity._TestDatabase.Helper.withIsolatedDatabase {

            @Dependency(\.identity) var identity

            await #expect(throws: Identity._TestDatabase.TestError.invalidResetToken) {
                try await identity.password.reset.confirm(newPassword: "newpass", token: "invalid-token")
            }

        }
    }
}

@Suite(
    "Email Management Tests"
)
struct EmailManagementTests {
    @Test("Successfully completes email change flow")
    func testEmailChangeFlow() async throws {
        try await Identity._TestDatabase.Helper.withIsolatedDatabase {

            @Dependency(\.identity) var identity

            let oldEmail = "old@example.com"
            let newEmail = "new@example.com"
            let password = "password123"

            // Setup: Create, verify and login user
            try await identity.create.client.request(email: oldEmail, password: password)
            try await identity.create.client.verify(email: oldEmail, token: "verification-token-\(oldEmail)")
            _ = try await identity.login(username: oldEmail, password: password)

            // Change email
            let result = try await identity.email.change.request(newEmail: newEmail)
            #expect(result == .success)

            let response = try await identity.email.change.confirm(token: "email-change-token-\(oldEmail)")
            #expect(response.accessToken.isEmpty == false)

            // Verify new email works
            let loginResponse = try await identity.login(username: newEmail, password: password)
            #expect(loginResponse.accessToken.isEmpty == false)

            // Verify old email doesn't work
            await #expect(throws: Identity._TestDatabase.TestError.invalidCredentials) {
                _ = try await identity.login(username: oldEmail, password: password)
            }

        }
    }
}
