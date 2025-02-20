//
//  File.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import Dependencies
import Testing
@testable import IdentityShared

// MARK: - Authentication Tests
@Suite("Authentication Tests")
struct AuthenticationTests {
    @Test("Successfully authenticates with valid credentials")
    func testValidCredentialsAuthentication() async throws {
        let client = Identity.Client.testValue
        let response = try await client.login(
            username: "test@example.com",
            password: "password123"
        )
        
        #expect(response.accessToken.value.isEmpty == false)
        #expect(response.refreshToken.value.isEmpty == false)
    }
    
    @Test("Successfully authenticates with API key")
    func testApiKeyAuthentication() async throws {
        let client = Identity.Client.testValue
        let response = try await client.login(apiKey: "valid-api-key")
        
        #expect(response.accessToken.value.isEmpty == false)
        #expect(response.refreshToken.value.isEmpty == false)
    }
    
    @Test("Successfully refreshes token")
    func testTokenRefresh() async throws {
        let client = Identity.Client.testValue
        let response = try await client.authenticate.token.refresh("valid-refresh-token")
        
        #expect(response.accessToken.value.isEmpty == false)
        #expect(response.refreshToken.value.isEmpty == false)
    }
}

// MARK: - Identity Creation Tests
@Suite("Identity Creation Tests")
struct IdentityCreationTests {
    @Test("Successfully creates new identity")
    func testIdentityCreation() async throws {
        let client = Identity.Client.testValue
        
        try await client.create.request(
            email: "new@example.com",
            password: "securePass123"
        )
        
        try await client.create.verify(
            email: "new@example.com",
            token: "verification-token"
        )
    }
    
    @Test("Successfully handles email verification")
    func testEmailVerification() async throws {
        let client = Identity.Client.testValue
        let verification = Identity.Creation.Verification(
            token: "valid-token",
            email: "new@example.com"
        )
        
        try await client.create.verify(verification)
    }
}

// MARK: - Password Management Tests
@Suite("Password Management Tests")
struct PasswordManagementTests {
    @Test("Successfully initiates password reset")
    func testPasswordResetRequest() async throws {
        let client = Identity.Client.testValue
        try await client.password.reset.request("user@example.com")
    }
    
    @Test("Successfully confirms password reset")
    func testPasswordResetConfirmation() async throws {
        let client = Identity.Client.testValue
        try await client.password.reset.confirm(
            newPassword: "newPass123",
            token: "reset-token"
        )
    }
    
    @Test("Successfully changes password for authenticated user")
    func testPasswordChange() async throws {
        let client = Identity.Client.testValue
        try await client.password.change.request(
            currentPassword: "currentPass",
            newPassword: "newPass123"
        )
    }
}

// MARK: - Email Management Tests
@Suite("Email Management Tests")
struct EmailManagementTests {
    @Test("Successfully requests email change")
    func testEmailChangeRequest() async throws {
        let client = Identity.Client.testValue
        let result = try await client.email.change.request("new@example.com")
        
        #expect(result == .success || result == .requiresReauthentication)
    }
    
    @Test("Successfully confirms email change")
    func testEmailChangeConfirmation() async throws {
        let client = Identity.Client.testValue
        let response = try await client.email.change.confirm("verification-token")
        
        #expect(response.accessToken.value.isEmpty == false)
        #expect(response.refreshToken.value.isEmpty == false)
    }
}

// MARK: - Identity Deletion Tests
@Suite("Identity Deletion Tests")
struct IdentityDeletionTests {
    @Test("Successfully initiates identity deletion")
    func testIdentityDeletionRequest() async throws {
        let client = Identity.Client.testValue
        try await client.delete.request("reauth-token")
    }
    
    @Test("Successfully cancels identity deletion")
    func testIdentityDeletionCancellation() async throws {
        let client = Identity.Client.testValue
        try await client.delete.cancel()
    }
    
    @Test("Successfully confirms identity deletion")
    func testIdentityDeletionConfirmation() async throws {
        let client = Identity.Client.testValue
        try await client.delete.confirm()
    }
}

// MARK: - Session Management Tests
@Suite("Session Management Tests")
struct SessionManagementTests {
    @Test("Successfully logs out user")
    func testLogout() async throws {
        let client = Identity.Client.testValue
        try await client.logout()
    }
    
    @Test("Successfully reauthorizes user")
    func testReauthorization() async throws {
        let client = Identity.Client.testValue
        let token = try await client.reauthorize("currentPassword")
        
        #expect(token.value.isEmpty == false)
    }
}
