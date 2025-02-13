import Dependencies
import EmailAddress
@testable import Identity_Consumer
@testable import Identity_Shared
import Testing
import URLRouting

@Suite("Identity Consumer Tests")
struct IdentityConsumerTests {

    // MARK: - Test Data

    let testEmail = try! EmailAddress("test@example.com")
    let testPassword = "securePassword123"
    let testToken = "valid-token-123"

    // MARK: - View Router Tests

    @Test("View Router handles create account routes")
    func testCreateAccountRoutes() throws {
        let router = Identity.Consumer.View.Router()

        // Test create request route
        var requestData = URLRequestData()
        requestData.method = "GET"
        requestData.path = ["create", "request"][...]

        let parsedRequestRoute = try router.parse(requestData)
        if case .create(.request) = parsedRequestRoute {
            // Route matched correctly
        } else {
            throw RouteError.invalidRoute
        }

        // Test create verify route
        var verifyData = URLRequestData()
        verifyData.method = "GET"
        verifyData.path = ["create", "email-verification"][...]
        verifyData.query = URLRequestData.Fields([
            "token": ["test-token"][...],
            "email": [testEmail.rawValue[...]][...]
        ], isNameCaseSensitive: true)

        let parsedVerifyRoute = try router.parse(verifyData)
        if case let .create(.verify(verify)) = parsedVerifyRoute {
            #expect(verify.token == "test-token")
            #expect(verify.email == testEmail.rawValue)
        } else {
            throw RouteError.invalidRoute
        }
    }

    @Test("View Router handles authentication routes")
    func testAuthenticationRoutes() throws {
        let router = Identity.Consumer.View.Router()

        // Test login route
        var loginData = URLRequestData()
        loginData.method = "GET"
        loginData.path = ["login"][...]

        let parsedLoginRoute = try router.parse(loginData)
        if case .login = parsedLoginRoute {
            // Route matched correctly
        } else {
            throw RouteError.invalidRoute
        }

        // Test logout route
        var logoutData = URLRequestData()
        logoutData.method = "GET"
        logoutData.path = ["logout"][...]

        let parsedLogoutRoute = try router.parse(logoutData)
        if case .logout = parsedLogoutRoute {
            // Route matched correctly
        } else {
            throw RouteError.invalidRoute
        }
    }

    @Test("View Router handles password management routes")
    func testPasswordRoutes() throws {
        let router = Identity.Consumer.View.Router()

        // Test password reset request route
        var resetRequestData = URLRequestData()
        resetRequestData.method = "GET"
        resetRequestData.path = ["password", "reset", "request"][...]

        let parsedResetRequestRoute = try router.parse(resetRequestData)
        if case .password(.reset(.request)) = parsedResetRequestRoute {
            // Route matched correctly
        } else {
            throw RouteError.invalidRoute
        }

        // Test password reset confirm route
        var resetConfirmData = URLRequestData()
        resetConfirmData.method = "GET"
        resetConfirmData.path = ["password", "reset", "confirm"][...]
        resetConfirmData.query = URLRequestData.Fields([
            "token": ["reset-token"][...],
            "newPassword": ["newPass123"][...]
        ], isNameCaseSensitive: true)

        let parsedResetConfirmRoute = try router.parse(resetConfirmData)
        if case let .password(.reset(.confirm(confirm))) = parsedResetConfirmRoute {
            #expect(confirm.token == "reset-token")
            #expect(confirm.newPassword == "newPass123")
        } else {
            throw RouteError.invalidRoute
        }
    }

    @Test("View Router handles email change routes")
    func testEmailChangeRoutes() throws {
        let router = Identity.Consumer.View.Router()

        // Test email change request route
        var requestData = URLRequestData()
        requestData.method = "GET"
        requestData.path = ["email-change", "request"][...]

        let parsedRequestRoute = try router.parse(requestData)
        if case .emailChange(.request) = parsedRequestRoute {
            // Route matched correctly
        } else {
            throw RouteError.invalidRoute
        }

        // Test email change confirm route
        var confirmData = URLRequestData()
        confirmData.method = "GET"
        confirmData.path = ["email-change", "confirm"][...]
        confirmData.query = URLRequestData.Fields([
            "token": ["change-token"][...]
        ], isNameCaseSensitive: true)

        let parsedConfirmRoute = try router.parse(confirmData)
        if case let .emailChange(.confirm(confirm)) = parsedConfirmRoute {
            #expect(confirm.token == "change-token")
        } else {
            throw RouteError.invalidRoute
        }
    }

    @Test("View Router handles MFA routes")
    func testMultifactorAuthenticationRoutes() throws {
        let router = Identity.Consumer.View.Router()

        // Test MFA setup route
        var setupData = URLRequestData()
        setupData.method = "GET"
        setupData.path = ["multifactor-authentication", "setup"][...]

        let parsedSetupRoute = try router.parse(setupData)
        if case .multifactorAuthentication(.setup) = parsedSetupRoute {
            // Route matched correctly
        } else {
            throw RouteError.invalidRoute
        }

        // Test MFA verify route
        var verifyData = URLRequestData()
        verifyData.method = "GET"
        verifyData.path = ["multifactor-authentication", "verify"][...]

        let parsedVerifyRoute = try router.parse(verifyData)
        if case .multifactorAuthentication(.verify) = parsedVerifyRoute {
            // Route matched correctly
        } else {
            throw RouteError.invalidRoute
        }

        // Test MFA manage route
        var manageData = URLRequestData()
        manageData.method = "GET"
        manageData.path = ["multifactor-authentication", "manage"][...]

        let parsedManageRoute = try router.parse(manageData)
        if case .multifactorAuthentication(.manage) = parsedManageRoute {
            // Route matched correctly
        } else {
            throw RouteError.invalidRoute
        }
    }

    // MARK: - Route Tests

    @Test("Consumer Route handles API and View routes")
    func testConsumerRoutes() throws {
        let router = Identity.Consumer.Route.Router()

        // Test API route
        var apiData = URLRequestData()
        apiData.method = "POST"
        apiData.path = ["api", "authenticate"][...]
        apiData.headers = URLRequestData.Fields([
            "Content-Type": ["application/x-www-form-urlencoded"][...]
        ], isNameCaseSensitive: false)

        let formData = "email=\(testEmail.rawValue)&password=\(testPassword)".data(using: .utf8)!
        apiData.body = formData

        let parsedApiRoute = try router.parse(apiData)
        if case .api(.authenticate(.credentials(let credentials))) = parsedApiRoute {
            #expect(credentials.email == testEmail.rawValue)
            #expect(credentials.password == testPassword)
        } else {
            throw RouteError.invalidRoute
        }

        // Test View route
        var viewData = URLRequestData()
        viewData.method = "GET"
        viewData.path = ["login"][...]

        let parsedViewRoute = try router.parse(viewData)
        if case .view(.login) = parsedViewRoute {
            // Route matched correctly
        } else {
            throw RouteError.invalidRoute
        }
    }

    enum RouteError: Error {
        case invalidRoute
    }
}
