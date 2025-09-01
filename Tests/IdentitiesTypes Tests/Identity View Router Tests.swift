//
//  Identity View Router Tests.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2025.
//

import Foundation
@testable import Identities
import Testing
import URLRouting

@Suite("Identity View Router Tests")
struct ViewRouterTests {
    
    let router = Identity.View.Router()
    
    @Test("Parse basic MFA routes")
    func testBasicMFARoutes() throws {
        // Test /mfa/manage
        let managePath = "/mfa/manage"
        let request = URLRequestData(path: managePath)
        let manageRoute = try router.parse(request)
        
        switch manageRoute {
        case .mfa(.manage):
            // Success
            break
        default:
            Issue.record("Expected .mfa(.manage) but got \(manageRoute)")
        }
        
        // Test /mfa/verify with query params
        let verifyPath = "/mfa/verify"
        let verifyRequest = URLRequestData(
            path: verifyPath,
            query: ["sessionToken": ["test-token"], "attemptsRemaining": ["3"]]
        )
        let verifyRoute = try router.parse(verifyRequest)
        if case .mfa(.verify(let challenge)) = verifyRoute {
            #expect(challenge.sessionToken == "test-token")
            #expect(challenge.attemptsRemaining == 3)
        } else {
            Issue.record("Expected MFA verify route")
        }
    }
    
    @Test("Parse TOTP routes")
    func testTOTPRoutes() throws {
        // Test /mfa/totp/setup
        let setupPath = "/mfa/totp/setup"
        let setupRequest = URLRequestData(path: setupPath)
        let setupRoute = try router.parse(setupRequest)
        if case .mfa(.totp(.setup)) = setupRoute {
            // Success
        } else {
            Issue.record("Expected .mfa(.totp(.setup)) but got \(setupRoute)")
        }
        
        // Test /mfa/totp/confirm
        let confirmPath = "/mfa/totp/confirm"
        let confirmRequest = URLRequestData(path: confirmPath)
        let confirmRoute = try router.parse(confirmRequest)
        if case .mfa(.totp(.confirmSetup)) = confirmRoute {
            // Success
        } else {
            Issue.record("Expected .mfa(.totp(.confirmSetup)) but got \(confirmRoute)")
        }
        
        // Test /mfa/totp/manage
        let managePath = "/mfa/totp/manage"
        let manageRequest = URLRequestData(path: managePath)
        let manageRoute = try router.parse(manageRequest)
        if case .mfa(.totp(.manage)) = manageRoute {
            // Success
        } else {
            Issue.record("Expected .mfa(.totp(.manage)) but got \(manageRoute)")
        }
    }
    
    @Test("Parse backup codes display route")
    func testBackupCodesDisplayRoute() throws {
        // Test /mfa/backup-codes (display)
        let displayPath = "/mfa/backup-codes"
        let displayRequest = URLRequestData(path: displayPath)
        let displayRoute = try router.parse(displayRequest)
        if case .mfa(.backupCodes(.display)) = displayRoute {
            // Success
        } else {
            Issue.record("Expected .mfa(.backupCodes(.display)) but got \(displayRoute)")
        }
    }
    
    @Test("Parse backup codes verify route")
    func testBackupCodesVerifyRoute() throws {
        // Test /mfa/backup-codes/verify with query params
        let verifyPath = "/mfa/backup-codes/verify"
        let verifyRequest = URLRequestData(
            path: verifyPath,
            query: ["sessionToken": ["test-token"], "attemptsRemaining": ["2"]]
        )
        let verifyRoute = try router.parse(verifyRequest)
        
        if case .mfa(.backupCodes(.verify(let challenge))) = verifyRoute {
            #expect(challenge.sessionToken == "test-token")
            #expect(challenge.attemptsRemaining == 2)
        } else {
            Issue.record("Expected backup codes verify route with challenge but got \(verifyRoute)")
        }
    }
    
    @Test("Parse backup codes verify route without attempts remaining")
    func testBackupCodesVerifyRouteDefaultAttempts() throws {
        // Test /mfa/backup-codes/verify with only sessionToken (default attemptsRemaining)
        let verifyPath = "/mfa/backup-codes/verify"
        let verifyRequest = URLRequestData(
            path: verifyPath,
            query: ["sessionToken": ["test-token"]]
        )
        let verifyRoute = try router.parse(verifyRequest)
        
        if case .mfa(.backupCodes(.verify(let challenge))) = verifyRoute {
            #expect(challenge.sessionToken == "test-token")
            #expect(challenge.attemptsRemaining == 3) // Default value
        } else {
            Issue.record("Expected backup codes verify route with default attempts but got \(verifyRoute)")
        }
    }
    
    @Test("Generate URLs for backup codes routes")
    func testGenerateBackupCodesURLs() throws {
        // Test generating display URL
        let displayRoute = Identity.View.mfa(.backupCodes(.display))
        let displayURL = try router.print(displayRoute)
        #expect(displayURL.path.joined(separator: "/") == "mfa/backup-codes")
        
        // Test generating verify URL
        let challenge = Identity.MFA.URLChallenge(
            sessionToken: "test-token",
            attemptsRemaining: 2
        )
        let verifyRoute = Identity.View.mfa(.backupCodes(.verify(challenge)))
        let verifyURL = try router.print(verifyRoute)
        #expect(verifyURL.path.joined(separator: "/") == "mfa/backup-codes/verify")
        #expect(verifyURL.query["sessionToken"]?.first == "test-token")
        #expect(verifyURL.query["attemptsRemaining"]?.first == "2")
    }
    
    @Test("Parse authentication routes")
    func testAuthenticationRoutes() throws {
        // Test /login
        let loginPath = "/login"
        let loginRequest = URLRequestData(path: loginPath)
        let loginRoute = try router.parse(loginRequest)
        if case .authenticate(.credentials) = loginRoute {
            // Success
        } else {
            Issue.record("Expected .authenticate(.credentials) but got \(loginRoute)")
        }
        
        // Test /credentials
        let credentialsPath = "/credentials"
        let credentialsRequest = URLRequestData(path: credentialsPath)
        let credentialsRoute = try router.parse(credentialsRequest)
        if case .authenticate(.credentials) = credentialsRoute {
            // Success
        } else {
            Issue.record("Expected .authenticate(.credentials) but got \(credentialsRoute)")
        }
        
        // Test /logout
        let logoutPath = "/logout"
        let logoutRequest = URLRequestData(path: logoutPath)
        let logoutRoute = try router.parse(logoutRequest)
        if case .logout = logoutRoute {
            // Success
        } else {
            Issue.record("Expected .logout but got \(logoutRoute)")
        }
    }
    
    @Test("Parse account management routes")
    func testAccountManagementRoutes() throws {
        // Test /create/request
        let createPath = "/create/request"
        let createRequest = URLRequestData(path: createPath)
        let createRoute = try router.parse(createRequest)
        if case .create(.request) = createRoute {
            // Success
        } else {
            Issue.record("Expected .create(.request) but got \(createRoute)")
        }
        
        // Test /delete
        let deletePath = "/delete"
        let deleteRequest = URLRequestData(path: deletePath)
        let deleteRoute = try router.parse(deleteRequest)
        if case .delete = deleteRoute {
            // Success
        } else {
            Issue.record("Expected .delete but got \(deleteRoute)")
        }
        
        // Test /password/reset/request
        let passwordResetPath = "/password/reset/request"
        let passwordResetRequest = URLRequestData(path: passwordResetPath)
        let passwordResetRoute = try router.parse(passwordResetRequest)
        if case .password(.reset(.request)) = passwordResetRoute {
            // Success
        } else {
            Issue.record("Expected .password(.reset(.request)) but got \(passwordResetRoute)")
        }
        
        // Test /email/change/request
        let emailChangePath = "/email/change/request"
        let emailChangeRequest = URLRequestData(path: emailChangePath)
        let emailChangeRoute = try router.parse(emailChangeRequest)
        if case .email(.change(.request)) = emailChangeRoute {
            // Success
        } else {
            Issue.record("Expected .email(.change(.request)) but got \(emailChangeRoute)")
        }
    }
    
    @Test("Comprehensive backup codes route parsing")
    func testComprehensiveBackupCodesRouting() throws {
        // Test various URL formats for backup codes
        let testCases: [(request: URLRequestData, isDisplay: Bool, description: String)] = [
            (URLRequestData(path: "/mfa/backup-codes"), true, "Display route"),
            (URLRequestData(path: "/mfa/backup-codes/"), true, "Display route with trailing slash"),
            // Note: These should fail because sessionToken is required
            // (URLRequestData(path: "/mfa/backup-codes/verify"), false, "Verify route without params"),
            // (URLRequestData(path: "/mfa/backup-codes/verify/"), false, "Verify route with trailing slash"),
            (URLRequestData(path: "/mfa/backup-codes/verify", query: ["sessionToken": ["abc"]]), false, "Verify with session token"),
            (URLRequestData(path: "/mfa/backup-codes/verify", query: ["sessionToken": ["abc"], "attemptsRemaining": ["5"]]), false, "Verify with all params"),
        ]
        
        for testCase in testCases {
            do {
                let route = try router.parse(testCase.request)
                if testCase.isDisplay {
                    if case .mfa(.backupCodes(.display)) = route {
                        // Success
                    } else {
                        Issue.record("\(testCase.description) failed - expected display but got \(route)")
                    }
                } else {
                    if case .mfa(.backupCodes(.verify)) = route {
                        // Success
                    } else {
                        Issue.record("\(testCase.description) failed - expected verify but got \(route)")
                    }
                }
            } catch {
                Issue.record("Failed to parse \(testCase.description): \(testCase.request) with error: \(error)")
            }
        }
    }
    
    @Test("Round-trip routing for backup codes")
    func testRoundTripBackupCodesRouting() throws {
        // Test display route round-trip
        let displayRoute = Identity.View.mfa(.backupCodes(.display))
        let displayURL = try router.print(displayRoute)
        let parsedDisplay = try router.parse(displayURL)
        if case .mfa(.backupCodes(.display)) = parsedDisplay {
            // Success
        } else {
            Issue.record("Round-trip failed for display route")
        }
        
        // Test verify route round-trip
        let challenge = Identity.MFA.URLChallenge(
            sessionToken: "round-trip-token",
            attemptsRemaining: 1
        )
        let verifyRoute = Identity.View.mfa(.backupCodes(.verify(challenge)))
        let verifyURL = try router.print(verifyRoute)
        let parsedVerify = try router.parse(verifyURL)
        
        if case .mfa(.backupCodes(.verify(let parsedChallenge))) = parsedVerify {
            #expect(parsedChallenge.sessionToken == "round-trip-token")
            #expect(parsedChallenge.attemptsRemaining == 1)
        } else {
            Issue.record("Round-trip failed for verify route")
        }
    }
}