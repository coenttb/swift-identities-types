//
//  Identity MFA Router Tests Simple.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 20/02/2025.
//

import Authenticating
import Dependencies
import DependenciesTestSupport
import EmailAddress
import Foundation
@testable import IdentitiesTypes
import Testing

@Suite("Simple MFA Router Tests")
struct SimpleMFARouterTests {
    
    let router: Identity.MFA.API.Router = .init()
    
    @Test("Creates correct URL for MFA status get")
    func testMFAStatusGet() throws {
        let mfa: Identity.MFA.API = .status(.get)
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/status")
        #expect(request.httpMethod == "GET")
    }
    
    @Test("Creates correct URL for MFA TOTP setup")
    func testMFATOTPSetup() throws {
        let mfa: Identity.MFA.API = .totp(.setup)
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/totp/setup")
        #expect(request.httpMethod == "POST")
    }
    
    @Test("Creates correct URL for MFA backup codes regenerate")
    func testMFABackupCodesRegenerate() throws {
        let mfa: Identity.MFA.API = .backupCodes(.regenerate)
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/backup-codes/regenerate")
        #expect(request.httpMethod == "POST")
    }
    
    @Test("Creates correct URL for MFA WebAuthn begin registration")
    func testMFAWebAuthnBeginRegistration() throws {
        let mfa: Identity.MFA.API = .webauthn(.beginRegistration)
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/webauthn/register/begin")
        #expect(request.httpMethod == "POST")
    }
}
