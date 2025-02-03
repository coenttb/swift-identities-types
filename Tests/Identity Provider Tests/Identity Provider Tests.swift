import Foundation
import Testing
import Dependencies
import EmailAddress
@testable import Identity_Provider

@Suite("Identity Provider Client Tests")
struct IdentityProviderClientTests {
    
    struct TestUser: Codable, Hashable, Sendable, Identifiable {
        let id: String
        let email: String
        let name: String?
        
        var ID: String { id }
    }
    
    typealias Client = Identity.Provider<TestUser>.Client
    
    // Test values
    let testEmail = try! EmailAddress("test@example.com")
    let testPassword = "securePassword123"
    let testUser = TestUser(id: "123", email: "test@example.com", name: "Test User")
    let testToken = "valid-token-123"
    
    // MARK: - Creation Tests
    
    @Test("Client handles user creation and verification")
    func testUserCreation() async throws {
        @Dependency(Client.self) var client
        
        // Valid creation should succeed
        try await client.create.request(testEmail, testPassword)
        
        // Invalid email should fail
        await #expect(throws: Swift.Error.self) {
            let invalidEmail = try EmailAddress("invalid")
            try await client.create.request(invalidEmail, testPassword)
        }
        
        // Weak password should fail
        await #expect(throws: Client.Create.ValidationError.weakPassword) {
            try await client.create.request(testEmail, "weak")
        }
        
        // Valid verification should succeed
        try await client.create.verify(testToken, testEmail)
        
        // Empty token should fail
        await #expect(throws: Client.Create.ValidationError.invalidToken) {
            try await client.create.verify("", testEmail)
        }
    }
    
    // MARK: - Password Management Tests
    
    @Test("Client handles password reset flow")
    func testPasswordReset() async throws {
        @Dependency(Client.self) var client
        
        // Valid reset request should succeed
        try await client.password.reset.request(testEmail)
        
        // Invalid email should fail
        await #expect(throws: Swift.Error.self) {
            let invalidEmail = try EmailAddress("invalid")
            try await client.password.reset.request(invalidEmail)
        }
        
        // Valid reset confirmation should succeed
        try await client.password.reset.confirm(testToken, "newSecurePass123")
        
        // Empty token should fail
        await #expect(throws: Client.Password.ValidationError.invalidToken) {
            try await client.password.reset.confirm("", "newSecurePass123")
        }
        
        // Weak password should fail
        await #expect(throws: Client.Password.ValidationError.weakPassword) {
            try await client.password.reset.confirm(testToken, "weak")
        }
    }
    
    @Test("Client handles password change with validation")
    func testPasswordChange() async throws {
        @Dependency(Client.self) var client
        
        // Valid password change should succeed
        try await client.password.change.request("oldPass123", "newPass456")
        
        // Same password should fail
        let samePassword = "password123"
        await #expect(throws: Client.Password.ValidationError.samePassword) {
            try await client.password.change.request(samePassword, samePassword)
        }
        
        // Weak new password should fail
        await #expect(throws: Client.Password.ValidationError.weakPassword) {
            try await client.password.change.request("oldPass123", "weak")
        }
    }
    
    // MARK: - Email Change Tests
    
    @Test("Client handles email change flow")
    func testEmailChange() async throws {
        @Dependency(Client.self) var client
        
        // Valid email change request should succeed
        try await client.emailChange.request(testEmail)
        
        // Nil email should fail
        await #expect(throws: Client.EmailChange.ValidationError.emailRequired) {
            try await client.emailChange.request(nil)
        }
        
        // Invalid email should fail
        await #expect(throws: Swift.Error.self) {
            let invalidEmail = try EmailAddress("invalid")
            try await client.emailChange.request(invalidEmail)
        }
        
        // Valid confirmation should succeed
        let newEmail = try await client.emailChange.confirm(testToken)
        
        #expect(testEmail == newEmail)
        
        // Empty token should fail
        await #expect(throws: Client.EmailChange.ValidationError.invalidToken) {
            try await client.emailChange.confirm("")
        }
    }
    
    // MARK: - Account Deletion Tests
    
    @Test("Client handles complete account deletion flow")
    func testAccountDeletion() async throws {
        @Dependency(Client.self) var client
        
        // Valid deletion request should succeed
        try await client.delete.request(UUID(), "valid-token")
        
        // Missing token should fail
        await #expect(throws: Client.Delete.ValidationError.missingToken) {
            try await client.delete.request(UUID(), "")
        }
        
        // Valid cancellation should succeed
        try await client.delete.cancel(testUser.id)
        
        // Invalid user ID should fail
        await #expect(throws: Client.Delete.ValidationError.invalidUserId) {
            try await client.delete.cancel("")
        }
        
        // Valid confirmation should succeed
        try await client.delete.confirm(testUser.id)
        
        // Invalid user ID should fail in confirmation
        await #expect(throws: Client.Delete.ValidationError.invalidUserId) {
            try await client.delete.confirm("")
        }
        
    }
    
    // MARK: - Authentication Flow Tests
    
    @Test("Client handles authentication flow")
    func testAuthenticationFlow() async throws {
        @Dependency(Client.self) var client
        
        // Test login
        try await client.login(testEmail, testPassword)
        
        // Invalid credentials should fail
        await #expect(throws: Client.ValidationError.invalidCredentials) {
            try await client.login(testEmail, "short")
        }
        
        // Test current user
        let currentUser = try await client.currentUser()
        #expect(currentUser == nil) // Default test implementation returns nil
        
        // Test user update
        let updatedUser = try await client.update(testUser)
        #expect(updatedUser == testUser) // Test implementation returns input
        
        // Test logout
        try await client.logout()
    }
}
