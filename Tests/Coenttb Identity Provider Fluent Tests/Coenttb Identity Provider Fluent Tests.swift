//  Coenttb_Identity_Provider_Fluent Tests.swift

import Foundation
import Coenttb_Web
import Identity_Provider_Fluent
import DependenciesTestSupport
import Testing

@Suite(
    "Coenttb_Identity_Provider_Fluent Creation Tests",
    .dependency(\.application, ApplicationKey.testValue)
)
struct IdentityLiveTests {
    // MARK: - Account Creation Tests
    
    @Test("Creating account succeeds with valid inputs")
    func testCreateAccountSuccess() async throws {
        @Dependency(\.application) var app
        let client = Coenttb_Identity.Client<TestUser>.liveTest
        
        try await client.create(
            email: EmailAddress("test@example.com"),
            password: "validPassword123!"
        )
        
        let identity = try await Identity.query(on: app.db)
            .filter(\.$email == "test@example.com")
            .first()
        
        #expect(identity != nil)
        #expect(identity?.email == "test@example.com")
        #expect(identity?.emailVerificationStatus == .unverified)
    }
    
    @Test("Creating duplicate account fails")
    func testCreateDuplicateAccountFails() async throws {
        @Dependency(\.application) var app
        let client = Coenttb_Identity.Client<TestUser>.liveTest
        let email = try EmailAddress("test@example.com")
        
        // Create first account
        try await client.create(email: email, password: "password123!")
        
        // Attempt to create duplicate should throw
        await #expect(throws: ValidationError.self) {
            try await client.create(email: email, password: "password123!")
        }
    }
    
    // MARK: - Email Verification Tests
    
    @Test("Email verification succeeds with valid token")
    func testEmailVerificationSuccess() async throws {
        @Dependency(\.application) var app
        let client = Coenttb_Identity.Client<TestUser>.liveTest
        let email = try EmailAddress("test@example.com")
        
        // Create unverified account
        try await client.create(email: email, password: "password123!")
        
        let identity = try await Identity.query(on: app.db)
            .filter(\.$email == email.rawValue)
            .first()
        
        let token = try identity?.generateToken(type: .emailVerification)
        try await token?.save(on: app.db)
        
        // Verify email
        try await client.verify(token: token!.value, email: email)
        
        // Check status updated
        let updatedIdentity = try await Identity.find(identity!.id, on: app.db)
        #expect(updatedIdentity?.emailVerificationStatus == .verified)
    }
    
    @Test("Email verification fails with invalid token")
    func testEmailVerificationFailsWithInvalidToken() async throws {
        @Dependency(\.application) var app
        let client = Coenttb_Identity.Client<TestUser>.liveTest
        let email = try EmailAddress("test@example.com")
        
        try await client.create(email: email, password: "password123!")
        
        await #expect(throws: Abort.self) {
            try await client.verify(token: "invalid-token", email: email)
        }
    }
    
    // MARK: - Login Tests
    
    @Test("Login succeeds with valid credentials")
    func testLoginSuccess() async throws {
        @Dependency(\.application) var app
        let client = Coenttb_Identity.Client<TestUser>.liveTest
        let email = try EmailAddress("test@example.com")
        let password = "password123!"
        
        // Create and verify account
        try await client.create(email: email, password: password)
        let identity = try await Identity.query(on: app.db)
            .filter(\.$email == email.rawValue)
            .first()
        identity?.emailVerificationStatus = .verified
        try await identity?.save(on: app.db)
        
        // Test login
        try await client.login(email: email, password: password)
    }
    
    @Test("Login fails with invalid password")
    func testLoginFailsWithInvalidPassword() async throws {
        @Dependency(\.application) var app
        let client = Coenttb_Identity.Client<TestUser>.liveTest
        let email = try EmailAddress("test@example.com")
        
        try await client.create(email: email, password: "correctpass123!")
        
        await #expect(throws: AuthenticationError.self) {
            try await client.login(email: email, password: "wrongpass123!")
        }
    }
    
    @Test("Login fails with unverified email")
    func testLoginFailsWithUnverifiedEmail() async throws {
        @Dependency(\.application) var app
        let client = Coenttb_Identity.Client<TestUser>.liveTest
        let email = try EmailAddress("test@example.com")
        let password = "password123!"
        
        try await client.create(email: email, password: password)
        
        await #expect(throws: AuthenticationError.self) {
            try await client.login(email: email, password: password)
        }
    }
    
    // MARK: - Password Reset Tests
    
    @Test("Password reset flow succeeds")
    func testPasswordResetSuccess() async throws {
        @Dependency(\.application) var app
        let client = Coenttb_Identity.Client<TestUser>.liveTest
        let email = try EmailAddress("test@example.com")
        
        // Create account
        try await client.create(email: email, password: "oldpass123!")
        
        // Request reset
        try await client.password.reset.request(email: email)
        
        // Get token
        let token = try await Identity.Token.query(on: app.db)
            .filter(\.$type == .passwordReset)
            .first()
        
        #expect(token != nil)
        
        // Confirm reset
        let newPassword = "newpass123!"
        try await client.password.reset.confirm(token: token!.value, newPassword: newPassword)
        
        // Verify email status and password reset token are updated
        let identity = try await Identity.query(on: app.db)
            .filter(\.$email == email.rawValue)
            .first()
        
        identity?.emailVerificationStatus = .verified
        try await identity?.save(on: app.db)
        
        // Verify can login with new password
        try await client.login(email: email, password: newPassword)
    }
}

@Suite(
    "Coenttb_Identity_Provider_Fluent EmailChange Tests",
    .dependency(\.application, ApplicationKey.testValue)
)
struct EmailChange {
    // MARK: - Email Change Tests

    @Test("Email change request fails without reauthorization")
    func testEmailChangeRequestFailsWithoutReauth() async throws {
        @Dependency(\.application) var app
        let client = Coenttb_Identity.Client<TestUser>.liveTest
        let currentEmail = try EmailAddress("current@example.com")
        
        // Create and verify initial account
        try await client.create(email: currentEmail, password: "password123!")
        let identity = try await Identity.query(on: app.db)
            .filter(\.$email == currentEmail.rawValue)
            .first()
        identity?.emailVerificationStatus = .verified
        try await identity?.save(on: app.db)
        
        // Attempt email change without reauth should fail
        let newEmail = try EmailAddress("new@example.com")
        await #expect(throws: Coenttb_Identity.Client<TestUser>.RequestEmailChangeError.self) {
            try await client.emailChange.request(newEmail: newEmail)
        }
    }

    @Test("Email change request succeeds with reauthorization")
    func testEmailChangeRequestSucceedsWithReauth() async throws {
        @Dependency(\.application) var app
        let currentEmail = try EmailAddress("current@example.com")
        let password = "password123!"
        
        // Create initial account
        let client = Client<TestUser>.makeTest()
        try await client.create(email: currentEmail, password: password)
        
        let identity = try await Identity.query(on: app.db)
            .filter(\.$email == currentEmail.rawValue)
            .first()
        identity?.emailVerificationStatus = .verified
        try await identity?.save(on: app.db)
        
        // Set up authenticated client
        let authenticatedClient = Client<TestUser>.makeTest(
            currentUserId: try identity!.requireID(),
            currentUserEmail: currentEmail
        )
        
        // First attempt should fail due to no reauthorization
        let newEmail = try EmailAddress("new@example.com")
        await #expect(throws: Coenttb_Identity.Client<TestUser>.RequestEmailChangeError.unauthorized) {
            try await authenticatedClient.emailChange.request(newEmail: newEmail)
        }
        
        // Create reauthorization token manually (simulating successful reauth)
        let reauthToken = try identity!.generateToken(type: .reauthenticationToken)
        try await reauthToken.save(on: app.db)
        
        // Now the email change request should succeed
        try await authenticatedClient.emailChange.request(newEmail: newEmail)
        
        // Verify email change request was created
        let emailChangeRequest = try await EmailChangeRequest.query(on: app.db)
            .filter(\.$identity.$id == identity!.id!)
            .first()
        
        #expect(emailChangeRequest != nil)
        #expect(emailChangeRequest?.newEmail == newEmail.rawValue)
        
    }

    @Test("Email change request fails for already used email")
    func testEmailChangeRequestFailsForUsedEmail() async throws {
        @Dependency(\.application) var app
        let client = Coenttb_Identity.Client<TestUser>.liveTest
        
        // Create first account
        let existingEmail = try EmailAddress("existing@example.com")
        try await client.create(email: existingEmail, password: "password123!")
        
        // Create second account that will try to change to existing email
        let currentEmail = try EmailAddress("current@example.com")
        try await client.create(email: currentEmail, password: "password123!")
        let identity = try await Identity.query(on: app.db)
            .filter(\.$email == currentEmail.rawValue)
            .first()
        identity?.emailVerificationStatus = .verified
        try await identity?.save(on: app.db)
        
        // Create reauth token
        let reauthToken = try identity?.generateToken(type: .reauthenticationToken)
        try await reauthToken?.save(on: app.db)
        
        // Attempt to change to existing email should fail
        // FAILS: Expectation failed: expected error of type ValidationError, but "unauthorized" of type RequestEmailChangeError was thrown instead: try await client.emailChange.request(newEmail: existingEmail) → unauthorized
        await #expect(throws: ValidationError.self) {
            try await client.emailChange.request(newEmail: existingEmail)
        }
    }

    @Test("Email change confirmation succeeds with valid token")
    func testEmailChangeConfirmationSuccess() async throws {
        @Dependency(\.application) var app
        let client = Coenttb_Identity.Client<TestUser>.liveTest
        let currentEmail = try EmailAddress("current@example.com")
        
        // Create and verify initial account
        try await client.create(email: currentEmail, password: "password123!")
        let identity = try await Identity.query(on: app.db)
            .filter(\.$email == currentEmail.rawValue)
            .first()
        identity?.emailVerificationStatus = .verified
        try await identity?.save(on: app.db)
        
        // Create reauth token
        let reauthToken = try identity?.generateToken(type: .reauthenticationToken)
        try await reauthToken?.save(on: app.db)
        
        // Request email change
        let newEmail = try EmailAddress("new@example.com")
        try await client.emailChange.request(newEmail: newEmail)
        
        // Get confirmation token
        let token = try await Identity.Token.query(on: app.db)
            .filter(\.$type == .emailChange)
            .first()
        
        #expect(token != nil)
        
        // Confirm change
        try await client.emailChange.confirm(token: token!.value)
        
        // Verify email was updated
        let updatedIdentity = try await Identity.find(identity!.id, on: app.db)
        #expect(updatedIdentity?.email == newEmail.rawValue)
        
        // Verify email change request was deleted
        let emailChangeRequest = try await EmailChangeRequest.query(on: app.db)
            .filter(\.$identity.$id == identity!.id!)
            .first()
        #expect(emailChangeRequest == nil)
    }

    @Test("Email change confirmation fails with invalid token")
    func testEmailChangeConfirmationFailsWithInvalidToken() async throws {
        @Dependency(\.application) var app
        let client = Coenttb_Identity.Client<TestUser>.liveTest
        let currentEmail = try EmailAddress("current@example.com")
        
        // Create and verify account
        try await client.create(email: currentEmail, password: "password123!")
        let identity = try await Identity.query(on: app.db)
            .filter(\.$email == currentEmail.rawValue)
            .first()
        identity?.emailVerificationStatus = .verified
        try await identity?.save(on: app.db)
        
        // Attempt to confirm with invalid token
        await #expect(throws: ValidationError.self) {
            try await client.emailChange.confirm(token: "invalid-token")
        }
    }

    @Test("Email change confirmation fails with expired token")
    func testEmailChangeConfirmationFailsWithExpiredToken() async throws {
        @Dependency(\.application) var app
        let client = Coenttb_Identity.Client<TestUser>.liveTest
        let currentEmail = try EmailAddress("current@example.com")
        
        // Create and verify initial account
        try await client.create(email: currentEmail, password: "password123!")
        let identity = try await Identity.query(on: app.db)
            .filter(\.$email == currentEmail.rawValue)
            .first()
        identity?.emailVerificationStatus = .verified
        try await identity?.save(on: app.db)
        
        // Create reauth token
        let reauthToken = try identity?.generateToken(type: .reauthenticationToken)
        try await reauthToken?.save(on: app.db)
        
        try await client.login(email: currentEmail, password: "password123!")
        
        // Request email change
        let newEmail = try EmailAddress("new@example.com")
        try await client.emailChange.request(newEmail: newEmail)
        
        // Get and expire token
        let token = try await Identity.Token.query(on: app.db)
            .filter(\.$type == .emailChange)
            .first()
        token?.validUntil = Date().addingTimeInterval(-3600) // Expire token
        try await token?.save(on: app.db)
        
        // Attempt to confirm with expired token
        await #expect(throws: Abort.self) {
            try await client.emailChange.confirm(token: token!.value)
        }
    }
}
