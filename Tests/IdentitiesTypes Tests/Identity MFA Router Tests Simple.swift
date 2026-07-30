//
//  Identity MFA Router Tests Simple.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 20/02/2025.
//

import Dependencies
import Dependencies_Test_Support
import EmailAddress
import Foundation
import Testing

@testable import IdentitiesTypes

extension Identity.MFA.API {
    @Suite
    struct Test {

        let router: Identity.MFA.API.Router = .init()

        @Test
        func `Creates correct URL for MFA status get`() throws {
            let mfa: Identity.MFA.API = .status(.get)

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/status")
            #expect(request.httpMethod == "GET")
        }

        @Test
        func `Creates correct URL for MFA TOTP setup`() throws {
            let mfa: Identity.MFA.API = .totp(.setup)

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/totp/setup")
            #expect(request.httpMethod == "POST")
        }

        @Test
        func `Creates correct URL for MFA backup codes regenerate`() throws {
            let mfa: Identity.MFA.API = .backupCodes(.regenerate)

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/backup-codes/regenerate")
            #expect(request.httpMethod == "POST")
        }

        @Test
        func `Creates correct URL for MFA Web Authn begin registration`() throws {
            let mfa: Identity.MFA.API = .webauthn(.beginRegistration)

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/webauthn/register/begin")
            #expect(request.httpMethod == "POST")
        }
    }
}
