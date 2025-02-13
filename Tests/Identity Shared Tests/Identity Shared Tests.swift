//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import Dependencies
import EmailAddress
import Foundation
@testable import Identity_Shared
import Testing
import URLRouting

@Suite("Identity Shared Tests")
struct IdentitySharedTests {

    // MARK: - Test Data

    let testEmail = try! EmailAddress("test@example.com")
    let testPassword = "securePassword123"
    let testToken = "valid-token-123"

    // MARK: - Authentication Tests

    @Test("Authentication credentials validation")
    func testAuthenticationCredentials() throws {
        let credentials = Identity.Authentication.Credentials(
            email: testEmail,
            password: testPassword
        )

        #expect(credentials.email == testEmail.rawValue)
        #expect(credentials.password == testPassword)
    }

    @Test("JWT Token Response structure")
    func testJWTResponse() {
        let accessToken = JWT.Token(
            value: "access-token",
            type: "Bearer",
            expiresIn: 3600
        )

        let refreshToken = JWT.Token(
            value: "refresh-token",
            type: "Bearer",
            expiresIn: 86400
        )

        let response = JWT.Response(
            accessToken: accessToken,
            refreshToken: refreshToken
        )

        #expect(response.accessToken.value == "access-token")
        #expect(response.refreshToken.value == "refresh-token")
        #expect(response.accessToken.type == "Bearer")
        #expect(response.refreshToken.type == "Bearer")
        #expect(response.accessToken.expiresIn == 3600)
        #expect(response.refreshToken.expiresIn == 86400)
    }

    // MARK: - Multifactor Authentication Tests

    @Test("MFA Method validation")
    func testMultifactorMethods() {
        let methods = Identity.Authentication.Multifactor.Method.allCases

        #expect(methods.contains(.totp))
        #expect(methods.contains(.sms))
        #expect(methods.contains(.email))
        #expect(methods.contains(.recoveryCode))
    }

    @Test("MFA Configuration state management")
    func testMultifactorConfiguration() {
        let methods: Set<Identity.Authentication.Multifactor.Method> = [.totp, .sms]
        let config = Identity.Authentication.Multifactor.Configuration(
            methods: methods,
            status: .enabled,
            lastVerifiedAt: .now
        )

        #expect(config.methods.count == 2)
        #expect(config.status == .enabled)
        #expect(config.lastVerifiedAt != nil)
    }

    @Test("MFA Challenge creation and validation")
    func testMultifactorChallenge() {
        let challenge = Identity.Authentication.Multifactor.Challenge(
            id: "challenge-123",
            method: .totp
        )

        #expect(challenge.id == "challenge-123")
        #expect(challenge.method == .totp)
        #expect(challenge.expiresAt > challenge.createdAt)
    }

    @Test("MFA Recovery codes management")
    func testMultifactorRecoveryCodes() {
        let codes = ["code1", "code2", "code3"]
        let usedCodes: Set<String> = ["code1"]

        let recovery = Identity.Authentication.Multifactor.Recovery.Codes(
            codes: codes,
            usedCodes: usedCodes
        )

        #expect(recovery.codes.count == 3)
        #expect(recovery.usedCodes.count == 1)
        #expect(recovery.remainingCodes == 2)
    }

    // MARK: - API Router Tests

    @Test("API Router path construction")
    func testAPIRouterPaths() throws {
        let router = Identity.API.Router()

        // Test create route
        let createRequest = Identity.Create.Request(email: testEmail, password: testPassword)
        var createData = URLRequestData()
        createData.method = "POST"
        createData.path = ["create", "request"][...]
        createData.headers = URLRequestData.Fields([
            "Content-Type": ["application/x-www-form-urlencoded"][...]
        ], isNameCaseSensitive: false)

        let formData = "email=\(testEmail.rawValue)&password=\(testPassword)".data(using: .utf8)!
        createData.body = formData

        let parsedCreateRoute = try router.parse(createData)
        if case let .create(.request(parsedRequest)) = parsedCreateRoute {
            #expect(parsedRequest.email == createRequest.email)
            #expect(parsedRequest.password == createRequest.password)
        } else {
            throw RouteError.invalidRoute
        }

        // Test authenticate route
        let credentials = Identity.Authentication.Credentials(email: testEmail, password: testPassword)
        var authData = URLRequestData()
        authData.method = "POST"
        authData.path = ["authenticate"][...]
        authData.headers = URLRequestData.Fields([
            "Content-Type": ["application/x-www-form-urlencoded"][...]
        ], isNameCaseSensitive: false)

        let authFormData = "email=\(testEmail.rawValue)&password=\(testPassword)".data(using: .utf8)!
        authData.body = authFormData

        let parsedAuthRoute = try router.parse(authData)
        if case let .authenticate(.credentials(parsedCredentials)) = parsedAuthRoute {
            #expect(parsedCredentials.email == credentials.email)
            #expect(parsedCredentials.password == credentials.password)
        } else {
            throw RouteError.invalidRoute
        }
    }

    enum RouteError: Error {
        case invalidRoute
    }

    // MARK: - API Request/Response Model Tests

    @Test("Create account request validation")
    func testCreateRequest() {
        let request = Identity.Create.Request(
            email: testEmail,
            password: testPassword
        )

        #expect(request.email == testEmail.rawValue)
        #expect(request.password == testPassword)
    }

    @Test("Password reset request validation")
    func testPasswordResetRequest() {
        let request = Password.Reset.Request(email: testEmail)
        #expect(request.email == testEmail.rawValue)

        let confirm = Password.Reset.Confirm(
            token: testToken,
            newPassword: "newPassword123"
        )
        #expect(confirm.token == testToken)
        #expect(confirm.newPassword == "newPassword123")
    }

    @Test("Email change request validation")
    func testEmailChangeRequest() {
        let request = Identity.EmailChange.Request(newEmail: testEmail)
        #expect(request.newEmail == testEmail.rawValue)

        let confirm = Identity.EmailChange.Confirm(token: testToken)
        #expect(confirm.token == testToken)
    }

    @Test("Client handles authentication")
    func testClientAuthentication() async throws {
        @Dependency(Identity.Client.self) var client

        // Test authentication with credentials
        let response = try await client.authenticate.credentials(
            Identity.Authentication.Credentials(
                email: testEmail,
                password: testPassword
            )
        )

        // Verify JWT response structure
        #expect(response.accessToken.type == "Bearer")
        #expect(response.refreshToken.type == "Bearer")
        #expect(response.accessToken.expiresIn > 0)
        #expect(response.refreshToken.expiresIn > response.accessToken.expiresIn)

        // Test token refresh
        let refreshResponse = try await client.authenticate.token.refresh(response.refreshToken.value)
        #expect(refreshResponse.accessToken.value != response.accessToken.value)

        // Test logout
        try await client.logout()
    }

    @Test("Client handles account management")
    func testClientAccountManagement() async throws {
        @Dependency(Identity.Client.self) var client

        // Test account creation
        try await client.create.request(testEmail, testPassword)
        try await client.create.verify(testEmail, testToken)

        // Test password management
        try await client.password.reset.request(testEmail)
        try await client.password.reset.confirm(testToken, "newSecurePass123")
        try await client.password.change.request(testPassword, "newSecurePass456")

        // Test email change
        try await client.emailChange.request(testEmail)
        try await client.emailChange.confirm(testToken)

        // Test reauthorization
        _ = try await client.reauthorize(testPassword)
    }

    @Test("Client handles MFA operations")
    func testClientMFA() async throws {
        @Dependency(Identity.Client.self) var client

        guard let mfa = client.multifactorAuthentication else {
            throw MFAError.notConfigured
        }

        // Test MFA setup
        let setupResponse = try await mfa.setup.initialize(.totp, "test-identifier")
        #expect(!setupResponse.secret.isEmpty)
        #expect(!setupResponse.recoveryCodes.isEmpty)

        try await mfa.setup.confirm("123456")

        // Test MFA verification
        let challenge = try await mfa.verification.createChallenge(.totp)
        #expect(challenge.method == .totp)
        #expect(challenge.expiresAt > challenge.createdAt)

        try await mfa.verification.verify(challenge.id, "123456")

        // Test MFA configuration
        let config = try await mfa.configuration()
        #expect(config.methods.contains(.totp))

        // Test recovery codes
        let remainingCodes = try await mfa.recovery.getRemainingCodeCount()
        #expect(remainingCodes > 0)

        let newCodes = try await mfa.recovery.generateNewCodes()
        #expect(!newCodes.isEmpty)

        // Test MFA disable
        try await mfa.disable()
    }

    enum MFAError: Error {
        case notConfigured
    }
}
