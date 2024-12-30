//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 13/12/2024.
//

import Foundation
import Testing
import DependenciesTestSupport
import EmailAddress
import Coenttb_Identity

@Suite("Coenttb_Identity Client Tests")
struct IdentityClientTests {
    
    // MARK: - Create Account Tests
    
    @Test("Create account succeeds with valid inputs")
    func testCreateAccountSuccess() async throws {
        var client = Client<TestUser>.testValue
        
        client.create = { email, password in
            #expect(email.rawValue == "test@example.com")
            #expect(password == "validPassword123!")
        }
        
        try await client.create(
            email: try EmailAddress("test@example.com"),
            password: "validPassword123!"
        )
    }
    
    // MARK: - Login Tests
    
    @Test("Login succeeds with valid credentials")
    func testLoginSuccess() async throws {
        var client = Client<TestUser>.testValue
        
        client.login = { email, password in
            #expect(email.rawValue == "test@example.com")
            #expect(password == "validPassword123!")
        }
        
        try await client.login(
            email: try EmailAddress("test@example.com"),
            password: "validPassword123!"
        )
    }
    
    // MARK: - Logout Tests
    
    @Test("Logout succeeds")
    func testLogoutSuccess() async throws {
        var client = Client<TestUser>.testValue
        var logoutCalled = false
        
        client.logout = {
            logoutCalled = true
        }
        
        try await client.logout()
        #expect(logoutCalled)
    }
    
    // MARK: - Email Verification Tests
    
    @Test("Verify email succeeds with valid token")
    func testVerifyEmailSuccess() async throws {
        var client = Client<TestUser>.testValue
        
        client.verify = { token, email in
            #expect(token == "valid-token-123")
            #expect(email.rawValue == "test@example.com")
        }
        
        try await client.verify(
            token: "valid-token-123",
            email: try EmailAddress("test@example.com")
        )
    }
    
    // MARK: - Password Reset Tests
    
    @Test("Password reset request succeeds")
    func testPasswordResetRequestSuccess() async throws {
        var client = Client<TestUser>.testValue
        
        client.password.reset.request = { email in
            #expect(email.rawValue == "test@example.com")
        }
        
        try await client.password.reset.request(
            email: try EmailAddress("test@example.com")
        )
    }
    
    @Test("Password reset confirmation succeeds")
    func testPasswordResetConfirmSuccess() async throws {
        var client = Client<TestUser>.testValue
        
        client.password.reset.confirm = { token, newPassword in
            #expect(token == "valid-token-123")
            #expect(newPassword == "newPassword123!")
        }
        
        try await client.password.reset.confirm(
            token: "valid-token-123",
            newPassword: "newPassword123!"
        )
    }
    
    // MARK: - Password Change Tests
    
    @Test("Password change succeeds")
    func testPasswordChangeSuccess() async throws {
        var client = Client<TestUser>.testValue
        
        client.password.change.request = { currentPassword, newPassword in
            #expect(currentPassword == "currentPass123!")
            #expect(newPassword == "newPass123!")
        }
        
        try await client.password.change.request(
            currentPassword: "currentPass123!",
            newPassword: "newPass123!"
        )
    }
    
    // MARK: - Email Change Tests
    
    @Test("Email change request succeeds")
    func testEmailChangeRequestSuccess() async throws {
        var client = Client<TestUser>.testValue
        
        client.emailChange.request = { newEmail in
            #expect(newEmail?.rawValue == "newemail@example.com")
        }
        
        try await client.emailChange.request(
            newEmail: try EmailAddress("newemail@example.com")
        )
    }
    
    @Test("Email change confirmation succeeds")
    func testEmailChangeConfirmSuccess() async throws {
        var client = Client<TestUser>.testValue
        
        client.emailChange.confirm = { token in
            #expect(token == "valid-token-123")
        }
        
        try await client.emailChange.confirm(token: "valid-token-123")
    }
    
    // MARK: - Current User Tests
    
    @Test("Current user fetch succeeds")
    func testCurrentUserFetchSuccess() async throws {
        var client = Client<TestUser>.testValue
        let expectedUser = TestUser(id: UUID(), email: "test@example.com")
        
        client.currentUser = {
            return expectedUser
        }
        
        let user = try await client.currentUser()
        #expect(user?.id == expectedUser.id)
        #expect(user?.email == expectedUser.email)
    }
    
    @Test("Current user returns nil when not logged in")
    func testCurrentUserNilWhenNotLoggedIn() async throws {
        var client = Client<TestUser>.testValue
        
        client.currentUser = {
            return nil
        }
        
        let user = try await client.currentUser()
        #expect(user == nil)
    }
    
    // MARK: - Update User Tests
    
    @Test("Update user succeeds")
    func testUpdateUserSuccess() async throws {
        var client = Client<TestUser>.testValue
        let updatedUser = TestUser(id: UUID(), email: "updated@example.com")
        
        client.update = { user in
            #expect(user?.email == "updated@example.com")
            return updatedUser
        }
        
        let result = try await client.update(updatedUser)
        #expect(result?.email == updatedUser.email)
    }
    
    // MARK: - Delete Account Tests
    
    @Test("Account deletion request succeeds")
    func testAccountDeletionRequestSuccess() async throws {
        var client = Client<TestUser>.testValue
        let userId = UUID()
        let deletionDate = Date()
        
        client.delete.request = { requestUserId, requestedAt in
            #expect(requestUserId == userId)
            #expect(Calendar.current.compare(requestedAt, to: deletionDate, toGranularity: .second) == .orderedSame)
        }
        
        try await client.delete.request(
            userId: userId,
            deletionRequestedAt: deletionDate
        )
    }
    
    @Test("Account deletion cancellation succeeds")
    func testAccountDeletionCancellationSuccess() async throws {
        var client = Client<TestUser>.testValue
        let userId = UUID()
        
        client.delete.cancel = { requestUserId in
            #expect(requestUserId == userId)
        }
        
        try await client.delete.cancel(userId: userId)
    }
}

// MARK: - Test Helpers

private struct TestUser: Codable, Equatable {
    let id: UUID
    let email: String
}
