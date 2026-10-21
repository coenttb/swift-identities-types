//
//  Identity View Router Tests.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2025.
//

import HTTP
import HTTP_Router
import Testing

@testable import IdentitiesTypes

extension Identity.View {
    @Suite
    struct `View Router Tests` {

        let router = Identity.View.self

        @Test
        func `Parse basic MFA routes`() throws {
            // Test /mfa/manage
            let managePath = "/mfa/manage"
            let request = RouteRequest.make(path: managePath)
            let manageRoute = try router.match(request: request)

            switch manageRoute {
            case .mfa(.manage):
                // Success
                break

            default:
                Issue.record("Expected .mfa(.manage) but got \(manageRoute)")
            }

            // Test /mfa/verify with query params
            let verifyPath = "/mfa/verify"
            let verifyRequest = RouteRequest.make(
                path: verifyPath,
                query: [("sessionToken", "test-token"), ("attemptsRemaining", "3")]
            )
            let verifyRoute = try router.match(request: verifyRequest)
            if case .mfa(.verify(let challenge)) = verifyRoute {
                #expect(challenge.sessionToken == "test-token")
                #expect(challenge.attemptsRemaining == 3)
            } else {
                Issue.record("Expected MFA verify route")
            }
        }

        @Test
        func `Parse TOTP routes`() throws {
            // Test /mfa/totp/setup
            let setupPath = "/mfa/totp/setup"
            let setupRequest = RouteRequest.make(path: setupPath)
            let setupRoute = try router.match(request: setupRequest)
            if case .mfa(.totp(.setup)) = setupRoute {
                // Success
            } else {
                Issue.record("Expected .mfa(.totp(.setup)) but got \(setupRoute)")
            }

            // Test /mfa/totp/confirm
            let confirmPath = "/mfa/totp/confirm"
            let confirmRequest = RouteRequest.make(path: confirmPath)
            let confirmRoute = try router.match(request: confirmRequest)
            if case .mfa(.totp(.confirmSetup)) = confirmRoute {
                // Success
            } else {
                Issue.record("Expected .mfa(.totp(.confirmSetup)) but got \(confirmRoute)")
            }

            // Test /mfa/totp/manage
            let managePath = "/mfa/totp/manage"
            let manageRequest = RouteRequest.make(path: managePath)
            let manageRoute = try router.match(request: manageRequest)
            if case .mfa(.totp(.manage)) = manageRoute {
                // Success
            } else {
                Issue.record("Expected .mfa(.totp(.manage)) but got \(manageRoute)")
            }
        }

        @Test
        func `Parse backup codes display route`() throws {
            // Test /mfa/backup-codes (display)
            let displayPath = "/mfa/backup-codes"
            let displayRequest = RouteRequest.make(path: displayPath)
            let displayRoute = try router.match(request: displayRequest)
            if case .mfa(.backupCodes(.display)) = displayRoute {
                // Success
            } else {
                Issue.record("Expected .mfa(.backupCodes(.display)) but got \(displayRoute)")
            }
        }

        @Test
        func `Parse backup codes verify route`() throws {
            // Test /mfa/backup-codes/verify with query params
            let verifyPath = "/mfa/backup-codes/verify"
            let verifyRequest = RouteRequest.make(
                path: verifyPath,
                query: [("sessionToken", "test-token"), ("attemptsRemaining", "2")]
            )
            let verifyRoute = try router.match(request: verifyRequest)

            if case .mfa(.backupCodes(.verify(let challenge))) = verifyRoute {
                #expect(challenge.sessionToken == "test-token")
                #expect(challenge.attemptsRemaining == 2)
            } else {
                Issue.record(
                    "Expected backup codes verify route with challenge but got \(verifyRoute)"
                )
            }
        }

        @Test
        func `Parse backup codes verify route without attempts remaining`() throws {
            // Test /mfa/backup-codes/verify with only sessionToken (default attemptsRemaining)
            let verifyPath = "/mfa/backup-codes/verify"
            let verifyRequest = RouteRequest.make(
                path: verifyPath,
                query: [("sessionToken", "test-token")]
            )
            let verifyRoute = try router.match(request: verifyRequest)

            if case .mfa(.backupCodes(.verify(let challenge))) = verifyRoute {
                #expect(challenge.sessionToken == "test-token")
                #expect(challenge.attemptsRemaining == 3)  // Default value
            } else {
                Issue.record(
                    "Expected backup codes verify route with default attempts but got \(verifyRoute)"
                )
            }
        }

        @Test
        func `Generate URLs for backup codes routes`() throws {
            // Test generating display URL.
            //
            // W3 semantic note: PointFree's `OneOf` printed via the LAST matching branch,
            // so `.display` used to print the bare default path "mfa/backup-codes". The
            // institute engine prints via the FIRST matching branch — the explicit
            // "/display" route. Parsing is unchanged (both the bare and the explicit form
            // still parse to `.display`); only the canonical printed URL moved.
            let displayRoute = Identity.View.mfa(.backupCodes(.display))
            let displayURL = try router.request(for: displayRoute)
            #expect(displayURL.pathComponents.joined(separator: "/") == "mfa/backup-codes/display")

            // Test generating verify URL
            let challenge = Identity.MFA.URLChallenge(
                sessionToken: "test-token",
                attemptsRemaining: 2
            )
            let verifyRoute = Identity.View.mfa(.backupCodes(.verify(challenge)))
            let verifyURL = try router.request(for: verifyRoute)
            #expect(verifyURL.pathComponents.joined(separator: "/") == "mfa/backup-codes/verify")
            #expect(verifyURL.queryItems["sessionToken"]?.first == "test-token")
            #expect(verifyURL.queryItems["attemptsRemaining"]?.first == "2")
        }

        @Test
        func `Parse authentication routes`() throws {
            // Test /login
            let loginPath = "/login"
            let loginRequest = RouteRequest.make(path: loginPath)
            let loginRoute = try router.match(request: loginRequest)
            if case .authenticate(.credentials) = loginRoute {
                // Success
            } else {
                Issue.record("Expected .authenticate(.credentials) but got \(loginRoute)")
            }

            // Test /credentials
            let credentialsPath = "/credentials"
            let credentialsRequest = RouteRequest.make(path: credentialsPath)
            let credentialsRoute = try router.match(request: credentialsRequest)
            if case .authenticate(.credentials) = credentialsRoute {
                // Success
            } else {
                Issue.record("Expected .authenticate(.credentials) but got \(credentialsRoute)")
            }

            // Test /logout
            let logoutPath = "/logout/view"
            let logoutRequest = RouteRequest.make(.post, path: logoutPath)
            let logoutRoute = try router.match(request: logoutRequest)
            if case .logout = logoutRoute {
                // Success
            } else {
                Issue.record("Expected .logout but got \(logoutRoute)")
            }
        }

        @Test
        func `Parse account management routes`() throws {
            // Test /create/request
            let createPath = "/create/request"
            let createRequest = RouteRequest.make(path: createPath)
            let createRoute = try router.match(request: createRequest)
            if case .create(.request) = createRoute {
                // Success
            } else {
                Issue.record("Expected .create(.request) but got \(createRoute)")
            }

            // Test /delete
            let deletePath = "/delete"
            let deleteRequest = RouteRequest.make(path: deletePath)
            let deleteRoute = try router.match(request: deleteRequest)
            if case .delete = deleteRoute {
                // Success
            } else {
                Issue.record("Expected .delete but got \(deleteRoute)")
            }

            // Test /password/reset/request
            let passwordResetPath = "/password/reset/request"
            let passwordResetRequest = RouteRequest.make(path: passwordResetPath)
            let passwordResetRoute = try router.match(request: passwordResetRequest)
            if case .password(.reset(.request)) = passwordResetRoute {
                // Success
            } else {
                Issue.record("Expected .password(.reset(.request)) but got \(passwordResetRoute)")
            }

            // Test /email/change/request
            let emailChangePath = "/email/change/request"
            let emailChangeRequest = RouteRequest.make(path: emailChangePath)
            let emailChangeRoute = try router.match(request: emailChangeRequest)
            if case .email(.change(.request)) = emailChangeRoute {
                // Success
            } else {
                Issue.record("Expected .email(.change(.request)) but got \(emailChangeRoute)")
            }
        }

        @Test
        func `Comprehensive backup codes route parsing`() throws {
            // Test various URL formats for backup codes
            let testCases: [(request: HTTP.Router.Request, isDisplay: Bool, description: String)] =
                [
                    (RouteRequest.make(path: "/mfa/backup-codes"), true, "Display route"),
                    (
                        RouteRequest.make(path: "/mfa/backup-codes/"), true,
                        "Display route with trailing slash"
                    ),
                    // Note: These should fail because sessionToken is required
                    // (RouteRequest.make(path: "/mfa/backup-codes/verify"), false, "Verify route without params"),
                    // (RouteRequest.make(path: "/mfa/backup-codes/verify/"), false, "Verify route with trailing slash"),
                    (
                        RouteRequest.make(
                            path: "/mfa/backup-codes/verify",
                            query: [("sessionToken", "abc")]
                        ),
                        false,
                        "Verify with session token"
                    ),
                    (
                        RouteRequest.make(
                            path: "/mfa/backup-codes/verify",
                            query: [("sessionToken", "abc"), ("attemptsRemaining", "5")]
                        ), false,
                        "Verify with all params"
                    ),
                ]

            for testCase in testCases {
                do {
                    let route = try router.match(request: testCase.request)
                    if testCase.isDisplay {
                        if case .mfa(.backupCodes(.display)) = route {
                            // Success
                        } else {
                            Issue.record(
                                "\(testCase.description) failed - expected display but got \(route)"
                            )
                        }
                    } else {
                        if case .mfa(.backupCodes(.verify)) = route {
                            // Success
                        } else {
                            Issue.record(
                                "\(testCase.description) failed - expected verify but got \(route)"
                            )
                        }
                    }
                } catch {
                    Issue.record(
                        "Failed to parse \(testCase.description): \(testCase.request) with error: \(error)"
                    )
                }
            }
        }

        @Test
        func `Round-trip routing for backup codes`() throws {
            // Test display route round-trip
            let displayRoute = Identity.View.mfa(.backupCodes(.display))
            let displayURL = try router.request(for: displayRoute)
            let parsedDisplay = try router.match(request: displayURL)
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
            let verifyURL = try router.request(for: verifyRoute)
            let parsedVerify = try router.match(request: verifyURL)

            if case .mfa(.backupCodes(.verify(let parsedChallenge))) = parsedVerify {
                #expect(parsedChallenge.sessionToken == "round-trip-token")
                #expect(parsedChallenge.attemptsRemaining == 1)
            } else {
                Issue.record("Round-trip failed for verify route")
            }
        }
    }
}
