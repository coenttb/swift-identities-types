import Testing
import Dependencies
import EmailAddress
@testable import Identity_Consumer

@Suite("Identity Consumer Client Tests")
struct IdentityConsumerClientTests {
    
    struct TestUser: Codable, Hashable, Sendable, Identifiable {
        let id: String
        let email: String
        let name: String?
        
        var ID: String { id }
    }
    
    typealias Client = Identity_Consumer<TestUser>.Client
    
    // Test values
    let testEmail = try! EmailAddress("test@example.com")
    let testPassword = "securePassword123"
    let testUser = TestUser(id: "123", email: "test@example.com", name: "Test User")
    
    // MARK: - Creation Tests
    
    @Test("Client handles user creation with validation")
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
    
    @Test("Client handles email change with validation")
    func testEmailChange() async throws {
        @Dependency(Client.self) var client
        
        // Valid email change should succeed
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
    }
    
    // MARK: - Account Deletion Tests
    
    @Test("Client handles account deletion flow")
    func testAccountDeletion() async throws {
        @Dependency(Client.self) var client
        
        // Valid deletion request should succeed
        try await client.delete.request(testUser.id, "valid-token")
        
        // Missing token should fail
        await #expect(throws: Client.Delete.ValidationError.missingToken) {
            try await client.delete.request(testUser.id, "")
        }
        
        // Valid cancellation should succeed
        try await client.delete.cancel(testUser.id)
        
        // Invalid user ID should fail
        await #expect(throws: Client.Delete.ValidationError.invalidUserId) {
            try await client.delete.cancel("")
        }
    }
    
    // MARK: - Authentication Flow Tests
    
    @Test("Client handles full authentication flow")
    func testAuthenticationFlow() async throws {
        @Dependency(Client.self) var client
        
        // Test login
        try await client.login(testEmail, testPassword)
        
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
