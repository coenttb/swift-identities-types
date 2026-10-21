//
//  Identity MFA Router Tests Simple.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 20/02/2025.
//

import Dependencies
import Dependencies_Test_Support
import EmailAddress
import Testing

@testable import IdentitiesTypes

extension Identity.MFA.API {
    @Suite
    struct Test {

        let router = Identity.MFA.API.self

        @Test
        func `Creates correct URL for MFA status get`() throws {
            let mfa: Identity.MFA.API = .status(.get)

            let request = try router.request(for: mfa)
            #expect(request.path == "/status")
            #expect(request.method.rawValue == "GET")
        }

        @Test
        func `Creates correct URL for MFA TOTP setup`() throws {
            let mfa: Identity.MFA.API = .totp(.setup)

            let request = try router.request(for: mfa)
            #expect(request.path == "/totp/setup")
            #expect(request.method.rawValue == "POST")
        }

        @Test
        func `Creates correct URL for MFA backup codes regenerate`() throws {
            let mfa: Identity.MFA.API = .backupCodes(.regenerate)

            let request = try router.request(for: mfa)
            #expect(request.path == "/backup-codes/regenerate")
            #expect(request.method.rawValue == "POST")
        }

        @Test
        func `Creates correct URL for MFA Web Authn begin registration`() throws {
            let mfa: Identity.MFA.API = .webauthn(.beginRegistration)

            let request = try router.request(for: mfa)
            #expect(request.path == "/webauthn/register/begin")
            #expect(request.method.rawValue == "POST")
        }
    }
}
