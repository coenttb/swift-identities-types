//
//  Detailed Route Debug Test.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2025.
//

import Testing

@testable import IdentitiesTypes

@Suite
struct `Detailed Route Debug` {

    @Test
    func `Debug backup codes routing issue`() throws {
        print("\n=== DEBUGGING BACKUP CODES ROUTE ===\n")

        let viewRouter = Identity.View.self

        // First, let's see what routes are being checked
        print("Testing /mfa/backup-codes/verify parsing...")

        let request = RouteRequest.make(
            path: "/mfa/backup-codes/verify",
            query: [("sessionToken", "test-token")]
        )

        do {
            let route = try viewRouter.match(request: request)
            print("✅ SUCCESS: Parsed route: \(route)")

            if case .mfa(.backupCodes(.verify(let challenge))) = route {
                print("   - Session token: \(challenge.sessionToken)")
                print("   - Attempts remaining: \(challenge.attemptsRemaining)")
            }
        } catch {
            print("❌ FAILED to parse: \(error)")
            print("\nDetailed error:")
            print(String(describing: error))
        }

        // Test the full route stack
        print("\n=== Testing Full Route Stack ===")
        let fullRouter = Identity.Route.self

        do {
            let fullRoute = try fullRouter.match(request: request)
            print("✅ Full router parsed: \(fullRoute)")
        } catch {
            print("❌ Full router failed: \(error)")
        }

        // Test without session token (should fail)
        print("\n=== Testing without session token (should fail) ===")
        let requestNoToken = RouteRequest.make(path: "/mfa/backup-codes/verify")

        do {
            let route = try viewRouter.match(request: requestNoToken)
            print("⚠️ Unexpectedly parsed without token: \(route)")
        } catch {
            print("✅ Correctly failed without token: \(error)")
        }

        // Print all the paths we're testing
        print("\n=== Path Components ===")
        print("Path string: /mfa/backup-codes/verify")
        print("Path components: \(request.path)")

        // Test route generation
        print("\n=== Testing Route Generation ===")
        let challenge = Identity.MFA.URLChallenge(
            sessionToken: "generated-token",
            attemptsRemaining: 2
        )
        let generatedRoute = Identity.View.mfa(.backupCodes(.verify(challenge)))

        do {
            let url = try viewRouter.request(for: generatedRoute)
            print("✅ Generated URL:")
            print("   Path: \(url.pathComponents.joined(separator: "/"))")
            print("   Query: \(url.queryItems)")
        } catch {
            print("❌ Failed to generate URL: \(error)")
        }
    }
}
