import Dependencies
import EmailAddress
@testable import Identity_Provider
@testable import Identity_Shared
import Testing
import URLRouting

@Suite("Identity Provider Tests")
struct IdentityProviderTests {

    let testEmail = try! EmailAddress("test@example.com")
    let testPassword = "securePassword123"
    let testToken = "valid-token-123"

    @Test("API handles authentication routes")
    func testAuthenticationAPI() throws {
        let router = Identity.API.Router()

        var credentialsData = URLRequestData()
        credentialsData.method = "POST"
        credentialsData.path = ["authenticate"][...]
        credentialsData.headers = URLRequestData.Fields([
            "Content-Type": ["application/x-www-form-urlencoded"][...]
        ], isNameCaseSensitive: false)

        let formData = "email=\(testEmail.rawValue)&password=\(testPassword)".data(using: .utf8)!
        credentialsData.body = formData

        let parsedCredentialsRoute = try router.parse(credentialsData)
        if case let .authenticate(.credentials(credentials)) = parsedCredentialsRoute {
            #expect(credentials.email == testEmail.rawValue)
            #expect(credentials.password == testPassword)
        } else {
            throw RouteError.invalidRoute
        }

        var tokenData = URLRequestData()
        tokenData.method = "POST"
        tokenData.path = ["authenticate", "access"][...]
        tokenData.headers = URLRequestData.Fields([
            "Authorization": ["Bearer \(testToken)"][...]
        ], isNameCaseSensitive: false)

        let parsedTokenRoute = try router.parse(tokenData)
        if case let .authenticate(.token(.access(auth))) = parsedTokenRoute {
            #expect(auth.token == testToken)
        } else {
            throw RouteError.invalidRoute
        }
    }

    @Test("API handles account management routes")
    func testAccountManagementAPI() throws {
        let router = Identity.API.Router()

        var createData = URLRequestData()
        createData.method = "POST"
        createData.path = ["create", "request"][...]
        createData.headers = URLRequestData.Fields([
            "Content-Type": ["application/x-www-form-urlencoded"][...]
        ], isNameCaseSensitive: false)

        let createFormData = "email=\(testEmail.rawValue)&password=\(testPassword)".data(using: .utf8)!
        createData.body = createFormData

        let parsedCreateRoute = try router.parse(createData)
        if case let .create(.request(request)) = parsedCreateRoute {
            #expect(request.email == testEmail.rawValue)
            #expect(request.password == testPassword)
        } else {
            throw RouteError.invalidRoute
        }

        var deleteData = URLRequestData()
        deleteData.method = "POST"
        deleteData.path = ["delete", "request"][...]
        deleteData.headers = URLRequestData.Fields([
            "Content-Type": ["application/x-www-form-urlencoded"][...]
        ], isNameCaseSensitive: false)

        let deleteFormData = "reauthToken=\(testToken)".data(using: .utf8)!
        deleteData.body = deleteFormData

        let parsedDeleteRoute = try router.parse(deleteData)
        if case .delete(.request) = parsedDeleteRoute {
        } else {
            throw RouteError.invalidRoute
        }
    }

    @Test("API handles password management routes")
    func testPasswordManagementAPI() throws {
        let router = Identity.API.Router()

        var resetData = URLRequestData()
        resetData.method = "POST"
        resetData.path = ["password", "reset", "request"][...]
        resetData.headers = URLRequestData.Fields([
            "Content-Type": ["application/x-www-form-urlencoded"][...]
        ], isNameCaseSensitive: false)

        let resetFormData = "email=\(testEmail.rawValue)".data(using: .utf8)!
        resetData.body = resetFormData

        let parsedResetRoute = try router.parse(resetData)
        if case let .password(.reset(.request(request))) = parsedResetRoute {
            #expect(request.email == testEmail.rawValue)
        } else {
            throw RouteError.invalidRoute
        }

        // Test password change
        var changeData = URLRequestData()
        changeData.method = "POST"
        changeData.path = ["password", "change", "request"][...]
        changeData.headers = URLRequestData.Fields([
            "Content-Type": ["application/x-www-form-urlencoded"][...]
        ], isNameCaseSensitive: false)

        let changeFormData = "currentPassword=oldPass&newPassword=newPass123".data(using: .utf8)!
        changeData.body = changeFormData

        let parsedChangeRoute = try router.parse(changeData)
        if case let .password(.change(.request(request))) = parsedChangeRoute {
            #expect(request.currentPassword == "oldPass")
            #expect(request.newPassword == "newPass123")
        } else {
            throw RouteError.invalidRoute
        }
    }

    @Test("API handles MFA routes")
    func testMultifactorAPI() throws {
        let router = Identity.API.Router()

        // Test MFA setup
        var setupData = URLRequestData()
        setupData.method = "POST"
        setupData.path = ["multifactor-authentication", "setup", "initialize"][...]
        setupData.headers = URLRequestData.Fields([
            "Content-Type": ["application/x-www-form-urlencoded"][...]
        ], isNameCaseSensitive: false)

        let setupRequest = Identity.Authentication.Multifactor.Setup.Request(
            method: .totp,
            identifier: "user123"
        )

        let setupFormData = "method=TOTP&identifier=user123".data(using: .utf8)!
        setupData.body = setupFormData

        let parsedSetupRoute = try router.parse(setupData)
        if case let .multifactorAuthentication(.setup(.initialize(request))) = parsedSetupRoute {
            #expect(request.method == .totp)
            #expect(request.identifier == "user123")
        } else {
            throw RouteError.invalidRoute
        }

        var verifyData = URLRequestData()
        verifyData.method = "POST"
        verifyData.path = ["multifactor-authentication", "verify"][...]
        verifyData.headers = URLRequestData.Fields([
            "Content-Type": ["application/x-www-form-urlencoded"][...]
        ], isNameCaseSensitive: false)

        let verification = Identity.Authentication.Multifactor.Verification(
            challengeId: "challenge123",
            code: "123456"
        )

        let verifyFormData = "challengeId=challenge123&code=123456".data(using: .utf8)!
        verifyData.body = verifyFormData

        let parsedVerifyRoute = try router.parse(verifyData)
        if case let .multifactorAuthentication(.verify(.verify(verification))) = parsedVerifyRoute {
            #expect(verification.challengeId == "challenge123")
            #expect(verification.code == "123456")
        } else {
            throw RouteError.invalidRoute
        }
    }

    @Test("Client handles authentication")
    func testClientAuthentication() async throws {
        @Dependency(Identity.Client.self) var client

        let response = try await client.authenticate.credentials(
            Identity.Authentication.Credentials(
                email: testEmail,
                password: testPassword
            )
        )

        #expect(response.accessToken.type == "Bearer")
        #expect(response.accessToken.expiresIn > 0)
        #expect(response.refreshToken.expiresIn > response.accessToken.expiresIn)

        let refreshResponse = try await client.authenticate.token.refresh(response.refreshToken.value)
        #expect(refreshResponse.accessToken.value != response.accessToken.value)

        let reAuthResponse = try await client.reauthorize(testPassword)
        #expect(reAuthResponse.accessToken.type == "Bearer")
    }

    @Test("Client handles account management")
    func testClientAccountManagement() async throws {
        @Dependency(Identity.Client.self) var client

        try await client.create.request(testEmail, testPassword)
        try await client.create.verify(testEmail, testToken)

        try await client.password.reset.request(testEmail)
        try await client.password.reset.confirm(testToken, "newSecurePass123")

        try await client.password.change.request(testPassword, "newSecurePass456")

        try await client.emailChange.request(testEmail)
        try await client.emailChange.confirm(testToken)
    }

    @Test("Client handles MFA operations")
    func testClientMFA() async throws {
        @Dependency(Identity.Client.self) var client

        guard let mfa = client.multifactorAuthentication else {
            throw MFAError.notConfigured
        }

        let setupResponse = try await mfa.setup.initialize(.totp, "test-identifier")
        #expect(!setupResponse.secret.isEmpty)
        #expect(!setupResponse.recoveryCodes.isEmpty)

        try await mfa.setup.confirm("123456")

        let challenge = try await mfa.verification.createChallenge(.totp)
        #expect(challenge.method == .totp)
        #expect(challenge.expiresAt > challenge.createdAt)

        try await mfa.verification.verify(challenge.id, "123456")

        let config = try await mfa.configuration()
        #expect(config.methods.contains(.totp))

        let remainingCodes = try await mfa.recovery.getRemainingCodeCount()
        #expect(remainingCodes > 0)

        let newCodes = try await mfa.recovery.generateNewCodes()
        #expect(!newCodes.isEmpty)
    }

    enum RouteError: Error {
        case invalidRoute
    }

    enum MFAError: Error {
        case notConfigured
    }
}
