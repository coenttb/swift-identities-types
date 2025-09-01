//
//  Detailed Route Debug Test.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2025.
//

import Foundation
@testable import Identities
import Testing
import URLRouting

@Suite("Detailed Route Debug")
struct DetailedRouteDebug {
    
    @Test("Debug backup codes routing issue")
    func debugBackupCodesRoute() throws {
        print("\n=== DEBUGGING BACKUP CODES ROUTE ===\n")
        
        let viewRouter = Identity.View.Router()
        
        // First, let's see what routes are being checked
        print("Testing /mfa/backup-codes/verify parsing...")
        
        let request = URLRequestData(
            path: "/mfa/backup-codes/verify",
            query: ["sessionToken": ["test-token"]]
        )
        
        do {
            let route = try viewRouter.parse(request)
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
        let fullRouter = Identity.Route.Router()
        
        do {
            let fullRoute = try fullRouter.parse(request)
            print("✅ Full router parsed: \(fullRoute)")
        } catch {
            print("❌ Full router failed: \(error)")
        }
        
        // Test without session token (should fail)
        print("\n=== Testing without session token (should fail) ===")
        let requestNoToken = URLRequestData(path: "/mfa/backup-codes/verify")
        
        do {
            let route = try viewRouter.parse(requestNoToken)
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
            let url = try viewRouter.print(generatedRoute)
            print("✅ Generated URL:")
            print("   Path: \(url.path.joined(separator: "/"))")
            print("   Query: \(url.query)")
        } catch {
            print("❌ Failed to generate URL: \(error)")
        }
    }
}