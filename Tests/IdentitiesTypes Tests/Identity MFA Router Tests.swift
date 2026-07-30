//
//  Identity MFA Router Tests Fixed.swift
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

extension Identity.MFA.API.Router {
    @Suite
    struct Test {

        let router: Identity.MFA.API.Router = .init()

        @Test
        func `Creates correct URL for MFA status get`() throws {
            let mfa: Identity.MFA.API = .status(.get)

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/status")
            #expect(request.httpMethod == "GET")

            let match = try router.match(request: request)
            #expect(match.is(\.status.get))
        }

        @Test
        func `Creates correct URL for MFA status challenge`() throws {
            let mfa: Identity.MFA.API = .status(.challenge)

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/status/challenge")
            #expect(request.httpMethod == "GET")

            let match = try router.match(request: request)
            #expect(match.is(\.status.challenge))
        }

        @Test
        func `Creates correct URL for MFA TOTP setup`() throws {
            let mfa: Identity.MFA.API = .totp(.setup)

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/totp/setup")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.totp.setup))
        }

        @Test
        func `Creates correct URL for MFA TOTP verification`() throws {
            let verifyRequest = Identity.MFA.TOTP.Verify(
                code: "123456",
                sessionToken: "session-token"
            )
            let mfa: Identity.MFA.API = .totp(.verify(verifyRequest))

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/totp/verify")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.totp.verify))
            #expect(Identity.MFA.API.cases.totp.verify.extract(match)?.code == "123456")
        }

        @Test
        func `Creates correct URL for MFA TOTP disable`() throws {
            let disableRequest = Identity.MFA.DisableRequest(reauthorizationToken: "reauth-token")
            let mfa: Identity.MFA.API = .totp(.disable(disableRequest))

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/totp/disable")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.totp.disable))
        }

        @Test
        func `Creates correct URL for MFA SMS setup`() throws {
            let setupRequest = Identity.MFA.SMS.Setup(phoneNumber: "+1234567890")
            let mfa: Identity.MFA.API = .sms(.setup(setupRequest))

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/sms/setup")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.sms.setup))
            #expect(Identity.MFA.API.cases.sms.setup.extract(match)?.phoneNumber == "+1234567890")
        }

        @Test
        func `Creates correct URL for MFA SMS verification`() throws {
            let verifyRequest = Identity.MFA.SMS.Verify(
                code: "123456",
                sessionToken: "session-token"
            )
            let mfa: Identity.MFA.API = .sms(.verify(verifyRequest))

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/sms/verify")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.sms.verify))
            #expect(Identity.MFA.API.cases.sms.verify.extract(match)?.code == "123456")
        }

        @Test
        func `Creates correct URL for MFA SMS request code`() throws {
            let mfa: Identity.MFA.API = .sms(.requestCode)

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/sms/request")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.sms.requestCode))
        }

        @Test
        func `Creates correct URL for MFA SMS disable`() throws {
            let disableRequest = Identity.MFA.DisableRequest(reauthorizationToken: "reauth-token")
            let mfa: Identity.MFA.API = .sms(.disable(disableRequest))

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/sms/disable")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.sms.disable))
        }

        @Test
        func `Creates correct URL for MFA Email setup`() throws {
            let setupRequest = Identity.MFA.Email.Setup(email: "mfa@example.com")
            let mfa: Identity.MFA.API = .email(.setup(setupRequest))

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/email/setup")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.email.setup))
            #expect(Identity.MFA.API.cases.email.setup.extract(match)?.email == "mfa@example.com")
        }

        @Test
        func `Creates correct URL for MFA Email verification`() throws {
            let verifyRequest = Identity.MFA.Email.Verify(
                code: "123456",
                sessionToken: "session-token"
            )
            let mfa: Identity.MFA.API = .email(.verify(verifyRequest))

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/email/verify")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.email.verify))
            #expect(Identity.MFA.API.cases.email.verify.extract(match)?.code == "123456")
        }

        @Test
        func `Creates correct URL for MFA Email request code`() throws {
            let mfa: Identity.MFA.API = .email(.requestCode)

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/email/request")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.email.requestCode))
        }

        @Test
        func `Creates correct URL for MFA Email disable`() throws {
            let disableRequest = Identity.MFA.DisableRequest(reauthorizationToken: "reauth-token")
            let mfa: Identity.MFA.API = .email(.disable(disableRequest))

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/email/disable")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.email.disable))
        }

        @Test
        func `Creates correct URL for MFA Backup Codes regenerate`() throws {
            let mfa: Identity.MFA.API = .backupCodes(.regenerate)

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/backup-codes/regenerate")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.backupCodes.regenerate))
        }

        @Test
        func `Creates correct URL for MFA Backup Codes verify`() throws {
            let verifyRequest = Identity.MFA.BackupCodes.Verify(
                code: "backup-code-123",
                sessionToken: "session-token"
            )
            let mfa: Identity.MFA.API = .backupCodes(.verify(verifyRequest))

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/backup-codes/verify")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.backupCodes.verify))
            #expect(
                Identity.MFA.API.cases.backupCodes.verify.extract(match)?.code == "backup-code-123"
            )
        }

        @Test
        func `Creates correct URL for MFA Web Authn begin registration`() throws {
            let mfa: Identity.MFA.API = .webauthn(.beginRegistration)

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/webauthn/register/begin")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.webauthn.beginRegistration))
        }

        @Test
        func `Creates correct URL for MFA Web Authn disable`() throws {
            let disableRequest = Identity.MFA.DisableRequest(reauthorizationToken: "reauth-token")
            let mfa: Identity.MFA.API = .webauthn(.disable(disableRequest))

            let request = try router.request(for: mfa)
            #expect(request.url?.path == "/webauthn/disable")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.webauthn.disable))
        }
    }
}
