//
//  ReadmeVerificationTests.swift
//  swift-identities-types
//
//  Validates that all code examples in README.md compile and work correctly.
//  Each test references specific line numbers in README.md.
//

import Dependencies
import DependenciesTestSupport
import JWT
import Testing

@testable import IdentitiesTypes

@Suite("README Verification Tests")
struct ReadmeVerificationTests {

  // MARK: - Quick Start Examples

  @Test("README lines 40-42: Import module")
  func testImportModule() {
    // Verifies the module can be imported
    let _: Identity.Type = Identity.self
  }

  @Test("README lines 49-66: Using main Identity type")
  func testMainIdentityType() async throws {
    try await Identity._TestDatabase.Helper.withIsolatedDatabase {
      @Dependency(\.identity) var identity

      // Create and verify identity
      try await identity.create.request(
        email: "new@example.com",
        password: "securePassword123"
      )
      try await identity.create.verify(
        email: "new@example.com",
        token: "verification-token-new@example.com"
      )

      // Authenticate with credentials
      let response = try await identity.login(
        username: "new@example.com",
        password: "securePassword123"
      )

      #expect(!response.accessToken.isEmpty)
      #expect(!response.refreshToken.isEmpty)
    }
  }

  // MARK: - Authentication Examples

  @Test("README lines 75-93: Credentials-based authentication")
  func testCredentialsAuthentication() async throws {
    try await Identity._TestDatabase.Helper.withIsolatedDatabase {
      @Dependency(\.identity) var identity

      // Setup test user
      try await identity.create.request(
        email: "user@example.com",
        password: "password123"
      )
      try await identity.create.verify(
        email: "user@example.com",
        token: "verification-token-user@example.com"
      )

      // Using convenience method
      let response = try await identity.login(
        username: "user@example.com",
        password: "password123"
      )
      #expect(!response.accessToken.isEmpty)
      #expect(!response.refreshToken.isEmpty)

      // Using credentials object
      let credentials = Identity.Authentication.Credentials(
        username: "user@example.com",
        password: "password123"
      )
      let response2 = try await identity.authenticate.credentials(credentials)
      #expect(!response2.accessToken.isEmpty)
    }
  }

  @Test("README lines 98-103: Token-based authentication")
  func testTokenAuthentication() async throws {
    try await Identity._TestDatabase.Helper.withIsolatedDatabase {
      @Dependency(\.identity) var identity

      // Setup test user
      try await identity.create.request(
        email: "token@example.com",
        password: "password123"
      )
      try await identity.create.verify(
        email: "token@example.com",
        token: "verification-token-token@example.com"
      )

      // Get initial tokens
      let initial = try await identity.login(
        username: "token@example.com",
        password: "password123"
      )

      // Validate access token
      try await identity.login(accessToken: initial.accessToken)

      // Refresh expired token
      let newTokens = try await identity.login(refreshToken: initial.refreshToken)
      #expect(!newTokens.accessToken.isEmpty)
    }
  }

  @Test("README lines 108-110: API key authentication")
  func testAPIKeyAuthentication() async throws {
    try await Identity._TestDatabase.Helper.withIsolatedDatabase {
      @Dependency(\.identity) var identity

      // API key auth would work if server supports it
      // Testing the type signature compiles
      let apiKeyAuthCompiles: (String) async throws -> Identity.Authentication.Response = identity
        .login(apiKey:)
      _ = apiKeyAuthCompiles
    }
  }

  // MARK: - Identity Creation Examples

  @Test("README lines 117-134: Identity creation flow")
  func testIdentityCreation() async throws {
    try await Identity._TestDatabase.Helper.withIsolatedDatabase {
      @Dependency(\.identity) var identity

      // Step 1: Request identity creation
      try await identity.create.request(
        email: "new@example.com",
        password: "securePassword123"
      )

      // Step 2: Verify email with token
      try await identity.create.verify(
        email: "new@example.com",
        token: "verification-token-new@example.com"
      )

      // Now the user can authenticate
      let response = try await identity.login(
        username: "new@example.com",
        password: "securePassword123"
      )
      #expect(!response.accessToken.isEmpty)
    }
  }

  // MARK: - Password Management Examples

  @Test("README lines 141-151: Password reset flow")
  func testPasswordReset() async throws {
    try await Identity._TestDatabase.Helper.withIsolatedDatabase {
      @Dependency(\.identity) var identity

      // Setup test user
      try await identity.create.request(
        email: "user@example.com",
        password: "password123"
      )
      try await identity.create.verify(
        email: "user@example.com",
        token: "verification-token-user@example.com"
      )

      // Step 1: Request password reset
      try await identity.password.reset.request(
        email: "user@example.com"
      )

      // Step 2: Confirm with token from email
      try await identity.password.reset.confirm(
        newPassword: "newSecurePassword123",
        token: "reset-token-user@example.com"
      )

      // Verify new password works
      let response = try await identity.login(
        username: "user@example.com",
        password: "newSecurePassword123"
      )
      #expect(!response.accessToken.isEmpty)
    }
  }

  @Test("README lines 156-161: Password change for authenticated user")
  func testPasswordChange() async throws {
    try await Identity._TestDatabase.Helper.withIsolatedDatabase {
      @Dependency(\.identity) var identity

      // Setup test user
      try await identity.create.request(
        email: "changepass@example.com",
        password: "currentPassword123"
      )
      try await identity.create.verify(
        email: "changepass@example.com",
        token: "verification-token-changepass@example.com"
      )

      // Authenticate
      _ = try await identity.login(
        username: "changepass@example.com",
        password: "currentPassword123"
      )

      // Change password while authenticated
      try await identity.password.change.request(
        currentPassword: "currentPassword123",
        newPassword: "newSecurePassword456"
      )

      // Verify new password works
      let response = try await identity.login(
        username: "changepass@example.com",
        password: "newSecurePassword456"
      )
      #expect(!response.accessToken.isEmpty)
    }
  }

  // MARK: - Email Management Examples

  @Test("README lines 166-176: Email management")
  func testEmailManagement() async throws {
    try await Identity._TestDatabase.Helper.withIsolatedDatabase {
      @Dependency(\.identity) var identity

      // Setup test user
      try await identity.create.request(
        email: "old@example.com",
        password: "password123"
      )
      try await identity.create.verify(
        email: "old@example.com",
        token: "verification-token-old@example.com"
      )

      // Authenticate
      _ = try await identity.login(
        username: "old@example.com",
        password: "password123"
      )

      // Request email change
      let result = try await identity.email.change.request(
        newEmail: "newemail@example.com"
      )
      #expect(result == .success)

      // Confirm email change with token
      let response = try await identity.email.change.confirm(
        token: "email-change-token-old@example.com"
      )
      // Response contains new access and refresh tokens
      #expect(!response.accessToken.isEmpty)
    }
  }

  // MARK: - Identity Deletion Examples

  @Test("README lines 181-191: Identity deletion")
  func testIdentityDeletion() async throws {
    try await Identity._TestDatabase.Helper.withIsolatedDatabase {
      @Dependency(\.identity) var identity

      // Setup test user
      try await identity.create.request(
        email: "delete@example.com",
        password: "password123"
      )
      try await identity.create.verify(
        email: "delete@example.com",
        token: "verification-token-delete@example.com"
      )

      // Authenticate
      _ = try await identity.login(
        username: "delete@example.com",
        password: "password123"
      )

      // Request deletion (using a test reauth token)
      try await identity.delete.request(
        reauthToken: "fresh-auth-token"
      )

      // Can cancel before confirming
      try await identity.delete.cancel()

      // Request again for confirmation test
      try await identity.delete.request(
        reauthToken: "fresh-auth-token"
      )

      // Confirm deletion (irreversible)
      try await identity.delete.confirm()
    }
  }

  // MARK: - Reauthorization Examples

  @Test("README lines 198-209: Reauthorization for sensitive operations")
  func testReauthorization() async throws {
    // Test the type signatures compile correctly
    @Dependency(\.identity) var identity

    // Verify reauthorization method signature
    let _: (String) async throws -> JWT = identity.reauthorize.reauthorize(password:)

    // Verify the JWT type is used in the API
    let request = Identity.Reauthorization.Request(password: "test")
    #expect(request.password == "test")

    // Note: Full integration test requires JWT support in test database
    // The types and API surface are verified here
  }

  // MARK: - URL Routing Examples

  @Test("README lines 216-236: Type-safe URL routing")
  func testTypesSafeRouting() throws {
    @Dependency(\.identity.router) var router

    // Generate URL for login API
    let api: Identity.API = .authenticate(
      .credentials(
        .init(username: "user@example.com", password: "password123")
      )
    )
    let request = try router.request(for: .api(api))
    #expect(request.url?.path == "/api/authenticate")
    #expect(request.httpMethod == "POST")

    // Generate URL for password reset view
    let viewRoute = Identity.Route.passwordReset
    let viewRequest = try router.request(for: viewRoute)
    #expect(viewRequest.url?.path == "/password/reset/request")

    // Parse incoming request
    let match = try router.match(request: request)
    #expect(match.is(\.authenticate.api.credentials))
    let credentials = match.authenticate?.api?.credentials
    #expect(credentials?.username == "user@example.com")
  }

  // MARK: - MFA Examples

  @Test("README lines 243-254: Multi-factor authentication")
  func testMFATypes() {
    // MFA types compile and are accessible
    let _: Identity.MFA.Method = .totp
    let _: Identity.MFA.Method = .sms
    let _: Identity.MFA.Method = .email
    let _: Identity.MFA.Method = .webauthn
    let _: Identity.MFA.Method = .backupCode

    // MFA challenge type
    let challenge = Identity.MFA.Challenge(
      sessionToken: "session-token",
      availableMethods: [.totp, .backupCode],
      expiresAt: Date(),
      attemptsRemaining: 3
    )
    #expect(challenge.sessionToken == "session-token")
    #expect(challenge.availableMethods.contains(.totp))
  }

  // MARK: - Testing Examples

  @Test("README lines 260-290: Testing with mock clients")
  func testMockClientPattern() async throws {
    // Use test dependency key
    try await Identity._TestDatabase.Helper.withIsolatedDatabase {
      @Dependency(\.identity) var identity

      // Create test user
      try await identity.create.request(
        email: "test@example.com",
        password: "testPassword123"
      )
      try await identity.create.verify(
        email: "test@example.com",
        token: "verification-token-test@example.com"
      )

      // Test authentication
      let response = try await identity.login(
        username: "test@example.com",
        password: "testPassword123"
      )

      #expect(!response.accessToken.isEmpty)
      #expect(!response.refreshToken.isEmpty)
    }
  }

  // MARK: - Type Structure Tests

  @Test("README lines 299-320: Domain architecture")
  func testDomainArchitecture() {
    @Dependency(\.identity) var identity

    // Verify main Identity structure
    let _: Identity.Authentication = identity.authenticate
    let _: Identity.Creation = identity.create
    let _: Identity.Deletion = identity.delete
    let _: Identity.Email = identity.email
    let _: Identity.Password = identity.password
    let _: Identity.Logout = identity.logout
    let _: Identity.Reauthorization = identity.reauthorize

    // Verify nested structures
    let _: Identity.Password.Reset = identity.password.reset
    let _: Identity.Password.Change = identity.password.change
    let _: Identity.Email.Change = identity.email.change

    // Verify optional MFA
    let _: Identity.MFA? = identity.mfa

    // Verify optional OAuth
    let _: Identity.OAuth? = identity.oauth
  }

  @Test("README lines 329-335: Type safety features")
  func testTypeSafety() {
    // All types are Sendable
    let _: any Sendable = Identity.Authentication.Credentials(
      username: "user@example.com",
      password: "password123"
    )

    // All types are Codable
    let _: any Codable = Identity.Authentication.Response(
      accessToken: "access",
      refreshToken: "refresh"
    )

    // All types are Equatable
    let credentials1 = Identity.Authentication.Credentials(
      username: "user@example.com",
      password: "password123"
    )
    let credentials2 = Identity.Authentication.Credentials(
      username: "user@example.com",
      password: "password123"
    )
    #expect(credentials1 == credentials2)
  }

  // MARK: - Additional Type Tests

  @Test("Verify Identity.Authentication.Response type")
  func testAuthenticationResponse() throws {
    let response = Identity.Authentication.Response(
      accessToken: "test-access-token",
      refreshToken: "test-refresh-token"
    )

    #expect(response.accessToken == "test-access-token")
    #expect(response.refreshToken == "test-refresh-token")

    // Test Codable conformance
    let encoder = JSONEncoder()
    let data = try encoder.encode(response)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(Identity.Authentication.Response.self, from: data)

    #expect(decoded == response)
  }

  @Test("Verify Identity.Creation.Request type")
  func testCreationRequest() throws {
    let request = Identity.Creation.Request(
      email: "new@example.com",
      password: "password123"
    )

    #expect(request.email == "new@example.com")
    #expect(request.password == "password123")

    // Test Codable conformance
    let encoder = JSONEncoder()
    let data = try encoder.encode(request)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(Identity.Creation.Request.self, from: data)

    #expect(decoded == request)
  }

  @Test("Verify Identity.Creation.Verification type")
  func testCreationVerification() throws {
    let verification = Identity.Creation.Verification(
      token: "verification-token",
      email: "verify@example.com"
    )

    #expect(verification.token == "verification-token")
    #expect(verification.email == "verify@example.com")

    // Test Codable conformance
    let encoder = JSONEncoder()
    let data = try encoder.encode(verification)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(Identity.Creation.Verification.self, from: data)

    #expect(decoded == verification)
  }

  @Test("Verify Identity.Password.Reset.Request type")
  func testPasswordResetRequest() throws {
    let request = Identity.Password.Reset.Request(
      email: "reset@example.com"
    )

    #expect(request.email == "reset@example.com")

    // Test Codable conformance
    let encoder = JSONEncoder()
    let data = try encoder.encode(request)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(Identity.Password.Reset.Request.self, from: data)

    #expect(decoded == request)
  }

  @Test("Verify Identity.Password.Reset.Confirm type")
  func testPasswordResetConfirm() throws {
    let confirm = Identity.Password.Reset.Confirm(
      token: "reset-token",
      newPassword: "newPassword123"
    )

    #expect(confirm.token == "reset-token")
    #expect(confirm.newPassword == "newPassword123")

    // Test Codable conformance
    let encoder = JSONEncoder()
    let data = try encoder.encode(confirm)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(Identity.Password.Reset.Confirm.self, from: data)

    #expect(decoded == confirm)
  }

  @Test("Verify Identity.Password.Change.Request type")
  func testPasswordChangeRequest() throws {
    let request = Identity.Password.Change.Request(
      currentPassword: "current123",
      newPassword: "new123"
    )

    #expect(request.currentPassword == "current123")
    #expect(request.newPassword == "new123")

    // Test Codable conformance
    let encoder = JSONEncoder()
    let data = try encoder.encode(request)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(Identity.Password.Change.Request.self, from: data)

    #expect(decoded == request)
  }

  @Test("Verify Identity.Email.Change.Request type")
  func testEmailChangeRequest() throws {
    let request = Identity.Email.Change.Request(
      newEmail: "newemail@example.com"
    )

    #expect(request.newEmail == "newemail@example.com")

    // Test Codable conformance
    let encoder = JSONEncoder()
    let data = try encoder.encode(request)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(Identity.Email.Change.Request.self, from: data)

    #expect(decoded == request)
  }

  @Test("Verify Identity.Email.Change.Confirmation type")
  func testEmailChangeConfirmation() throws {
    let confirmation = Identity.Email.Change.Confirmation(
      token: "confirmation-token"
    )

    #expect(confirmation.token == "confirmation-token")

    // Test Codable conformance
    let encoder = JSONEncoder()
    let data = try encoder.encode(confirmation)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(Identity.Email.Change.Confirmation.self, from: data)

    #expect(decoded == confirmation)
  }

  @Test("Verify Identity.Deletion.Request type")
  func testDeletionRequest() throws {
    let request = Identity.Deletion.Request(
      reauthToken: "reauth-token-123"
    )

    #expect(request.reauthToken == "reauth-token-123")

    // Test Codable conformance
    let encoder = JSONEncoder()
    let data = try encoder.encode(request)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(Identity.Deletion.Request.self, from: data)

    #expect(decoded == request)
  }

  @Test("Verify Identity.Reauthorization.Request type")
  func testReauthorizationRequest() throws {
    let request = Identity.Reauthorization.Request(
      password: "password123"
    )

    #expect(request.password == "password123")

    // Test Codable conformance
    let encoder = JSONEncoder()
    let data = try encoder.encode(request)

    let decoder = JSONDecoder()
    let decoded = try decoder.decode(Identity.Reauthorization.Request.self, from: data)

    #expect(decoded == request)
  }
}
