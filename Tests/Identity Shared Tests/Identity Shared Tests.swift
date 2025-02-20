//
//  File.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import Dependencies
import EmailAddress
import Testing
@testable import Identity_Shared
import DependenciesTestSupport

struct TestHelper {
    static let enabled: Bool = true
    /// Creates an isolated test environment for each test
    static func withIsolatedDatabase(_ operation: @escaping () async throws -> Void) async throws {
        if enabled {
            let database = Identity.Client.TestDatabase()
            try await withDependencies {
                $0[Identity.Client.TestDatabase.self] = database
                $0[Identity.Client.self] = .testValue
            } operation: {
                try await operation()
            }
        } else {
            try await operation()
        }
    }
}

// MARK: - Authentication Tests
@Suite(
    "Authentication Tests"
)
struct AuthenticationTests {
    @Test("Successfully authenticates with valid credentials")
    func testValidCredentialsAuthentication() async throws {
        try await TestHelper.withIsolatedDatabase {
            
            @Dependency(Identity.Client.self) var client
            
            let email = "auth@example.com"
            let password = "password123"
            
            try await client.create.request(email: email, password: password)
            try await client.create.verify(email: email, token: "verification-token-\(email)")
            
            let response = try await client.login(username: email, password: password)
            
            #expect(response.accessToken.value.isEmpty == false)
            #expect(response.refreshToken.value.isEmpty == false)
            #expect(response.accessToken.expiresIn == 3600) // 1 hour
            #expect(response.refreshToken.expiresIn == 86400) // 24 hours
        }
    }
    
    @Test("Fails authentication with invalid credentials")
    func testInvalidCredentialsAuthentication() async throws {
        try await TestHelper.withIsolatedDatabase {
            
            @Dependency(Identity.Client.self) var client
            
            
            await #expect(throws: Identity.Client.TestDatabase.TestError.invalidCredentials) {
                try await client.login(username: "nonexistent@example.com", password: "wrongpass")
            }
            
        }
    }
    
    @Test("Successfully authenticates with API key")
    func testApiKeyAuthentication() async throws {
        try await TestHelper.withIsolatedDatabase {
            
            @Dependency(Identity.Client.self) var client
            
            let response = try await client.login(apiKey: "valid-api-key")
            
            #expect(response.accessToken.value == "api-access-token")
            #expect(response.refreshToken.value == "api-refresh-token")
            
        }
    }
    
    @Test("Successfully refreshes token")
    func testTokenRefresh() async throws {
        try await TestHelper.withIsolatedDatabase {
            
            @Dependency(Identity.Client.self) var client
            
            let email = "refresh@example.com"
            let password = "password123"
            
            
            try await client.create.request(email: email, password: password)
            try await client.create.verify(email: email, token: "verification-token-\(email)")
            let initialResponse = try await client.authenticate.credentials(username: email, password: password)
            
            // Refresh token
            let refreshedResponse = try await client.authenticate.token.refresh(initialResponse.refreshToken.value)
            
            
            
        }
    }
}

// MARK: - Identity Creation Tests
@Suite(
    "Identity Creation Tests"
)
struct IdentityCreationTests {
    @Test("Successfully creates new identity")
    func testIdentityCreation() async throws {
        try await TestHelper.withIsolatedDatabase {
            
            @Dependency(Identity.Client.self) var client
            
            let email = "new@example.com"
            let password = "securePass123"
            
            try await client.create.request(email: email, password: password)
            try await client.create.verify(email: email, token: "verification-token-\(email)")
            
            let response = try await client.login(username: email, password: password)
            #expect(response.accessToken.value.isEmpty == false)
            
        }
    }
    
    @Test("Fails verification with invalid token")
    func testInvalidVerificationToken() async throws {
        try await TestHelper.withIsolatedDatabase {
            
            @Dependency(Identity.Client.self) var client
            
            let email = "invalid@example.com"
            
            try await client.create.request(email: email, password: "password123")
            
            await #expect(throws: Identity.Client.TestDatabase.TestError.invalidVerificationToken) {
                try await client.create.verify(email: email, token: "wrong-token")
            }
            
        }
    }
    
    @Test("Prevents duplicate email registration")
    func testDuplicateEmailPrevention() async throws {
        try await TestHelper.withIsolatedDatabase {
            
            @Dependency(Identity.Client.self) var client
            @Dependency(Identity.Client.TestDatabase.self) var database
            let email = "duplicate@example.com"
            
            try await client.create.request(email: email, password: "password123")
            
            await #expect(throws: Identity.Client.TestDatabase.TestError.emailAlreadyExists) {
                try await client.create.request(email: email, password: "anotherpass")
            }
            
        }
    }
}

// MARK: - Password Management Tests
@Suite(
    "Password Management Tests"
)
struct PasswordManagementTests {
    @Test("Successfully completes password reset flow")
    func testPasswordResetFlow() async throws {
        try await TestHelper.withIsolatedDatabase {
            
            @Dependency(Identity.Client.self) var client
            @Dependency(Identity.Client.TestDatabase.self) var database
            let email = "reset@example.com"
            let initialPassword = "initial123"
            let newPassword = "newPass123"
            
            // Setup: Create and verify user
            try await client.create.request(email: email, password: initialPassword)
            try await client.create.verify(email: email, token: "verification-token-\(email)")
            
            // Request and confirm reset
            try await client.password.reset.request(email)
            try await client.password.reset.confirm(newPassword: newPassword, token: "reset-token-\(email)")
            
            // Verify new password works
            let response = try await client.login(username: email, password: newPassword)
            #expect(response.accessToken.value.isEmpty == false)
            
            // Verify old password doesn't work
            await #expect(throws: Identity.Client.TestDatabase.TestError.invalidCredentials) {
                _ = try await client.login(username: email, password: initialPassword)
            }
            
        }
    }
    
    @Test("Successfully changes password for authenticated user")
    func testPasswordChange() async throws {
        try await TestHelper.withIsolatedDatabase {
            
            @Dependency(Identity.Client.self) var client
            @Dependency(Identity.Client.TestDatabase.self) var database
            let email = "change@example.com"
            let currentPassword = "current123"
            let newPassword = "new123"
            
            // Setup: Create, verify, and login user
            try await client.create.request(email: email, password: currentPassword)
            try await client.create.verify(email: email, token: "verification-token-\(email)")
            _ = try await client.login(username: email, password: currentPassword)
            
            // Change password
            try await client.password.change.request(
                currentPassword: currentPassword,
                newPassword: newPassword
            )
            
            // Verify new password works
            let response = try await client.login(username: email, password: newPassword)
            #expect(response.accessToken.value.isEmpty == false)
            
            // Verify old password doesn't work
            await #expect(throws: Identity.Client.TestDatabase.TestError.invalidCredentials) {
                _ = try await client.login(username: email, password: currentPassword)
            }
            
        }
    }
    
    @Test("Fails password reset with invalid token")
    func testInvalidResetToken() async throws {
        try await TestHelper.withIsolatedDatabase {
            
            @Dependency(Identity.Client.self) var client
            @Dependency(Identity.Client.TestDatabase.self) var database
            
            await #expect(throws: Identity.Client.TestDatabase.TestError.invalidResetToken) {
                try await client.password.reset.confirm(newPassword: "newpass", token: "invalid-token")
            }
            
        }
    }
}

// MARK: - Email Management Tests
@Suite(
    "Email Management Tests"
)
struct EmailManagementTests {
    @Test("Successfully completes email change flow")
    func testEmailChangeFlow() async throws {
        try await TestHelper.withIsolatedDatabase {
            
            @Dependency(Identity.Client.self) var client
            
            let oldEmail = "old@example.com"
            let newEmail = "new@example.com"
            let password = "password123"
            
            // Setup: Create, verify and login user
            try await client.create.request(email: oldEmail, password: password)
            try await client.create.verify(email: oldEmail, token: "verification-token-\(oldEmail)")
            _ = try await client.login(username: oldEmail, password: password)
            
            // Change email
            let result = try await client.email.change.request(newEmail)
            #expect(result == .success)
            
            let response = try await client.email.change.confirm("email-change-token-\(oldEmail)")
            #expect(response.accessToken.value.isEmpty == false)
            
            // Verify new email works
            let loginResponse = try await client.login(username: newEmail, password: password)
            #expect(loginResponse.accessToken.value.isEmpty == false)
            
            // Verify old email doesn't work
            await #expect(throws: Identity.Client.TestDatabase.TestError.invalidCredentials) {
                _ = try await client.login(username: oldEmail, password: password)
            }
            
        }
    }
}


//// MARK: - Identity Deletion Tests
///try await TestHelper.withIsolatedDatabase {

///
//@Suite(
//    "Identity Deletion Tests"
//)
//struct IdentityDeletionTests {
//    @Test("Successfully completes deletion flow")
//    func testDeletionFlow() async throws {
//        @Dependency(Identity.Client.self) var client}

//        let email = "delete@example.com"
//try await TestHelper.withIsolatedDatabase {
    
    //        let password = "password123"
    //
    //        // Setup: Create, verify and login user
    //        try await client.create.request(email: email, password: password)
    //        try await client.create.verify(email: email, token: "verification-token")
    //        _ = try await client.login(username: email, password: password)
    //
    //        // Delete account
    //        let reauthToken = try await client.reauthorize(password)
    //        try await client.delete.request(reauthToken.value)
    //        try await client.delete.confirm()
    //
    //        // Verify cannot login
    //        await #expect(throws: Identity.Client.TestDatabase.TestError.invalidCredentials) {
    //            _ = try await client.login(username: email, password: password)
    //        }
    //    }
    //
    //    @Test("Successfully cancels deletion request")
    //    func testDeletionCancellation() async throws {
    //        @Dependency(Identity.Client.self) var client
//}

//        let email = "cancel@example.com"
//        let password = "password123"
//
//        // Setup: Create, verify and login user
//        try await client.create.request(email: email, password: password)
//        try await client.create.verify(email: email, token: "verification-token")
//        _ = try await client.login(username: email, password: password)
//
//        // Start and cancel deletion
//        let reauthToken = try await client.reauthorize(password)
//        try await client.delete.request(reauthToken.value)
//        try await client.delete.cancel()
//
//        // Verify can still login
//        let response = try await client.login(username: email, password: password)
//        #expect(response.accessToken.value.isEmpty == false)
//    }
//}

//// MARK: - Session Management Tests
///try await TestHelper.withIsolatedDatabase {

///
//@Suite(
//    "Session Management Tests"
//)
//struct SessionManagementTests {
//    @Test("Successfully manages session lifecycle")
//    func testSessionLifecycle() async throws {
//        @Dependency(Identity.Client.self) var client}

//        let email = "session@example.com"
//        let password = "password123"
//
//        // Setup: Create and verify user
//        try await client.create.request(email: email, password: password)
//        try await client.create.verify(email: email, token: "verification-token")
//
//        // Login and get tokens
//        let loginResponse = try await client.login(username: email, password: password)
//        #expect(loginResponse.accessToken.value.isEmpty == false)
//
//        // Reauthorize
//        let reauthToken = try await client.reauthorize(password)
//        #expect(reauthToken.value.isEmpty == false)
//
//        // Logout
//        try await client.logout()
//
//        // Verify token is invalidated
//        await #expect(throws: Identity.Client.TestDatabase.TestError.invalidToken) {
//            try await client.authenticate.token.refresh(loginResponse.refreshToken.value)
//        }
//    }
//}
