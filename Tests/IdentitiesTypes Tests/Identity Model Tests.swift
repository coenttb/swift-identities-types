//
//  Identity Model Tests.swift
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

extension Identity.Creation.Request {
    @Suite
    struct Test {

        @Test
        func `Creates identity creation request`() {
            let request = Identity.Creation.Request(
                email: "new@example.com",
                password: "password123"
            )

            #expect(request.email == "new@example.com")
            #expect(request.password == "password123")
        }

        @Test
        func `Creates identity verification request`() {
            let verification = Identity.Creation.Verification(
                token: "verification-token-123",
                email: "verify@example.com"
            )

            #expect(verification.email == "verify@example.com")
            #expect(verification.token == "verification-token-123")
        }

        @Test
        func `Creation request encoding and decoding`() throws {
            let request = Identity.Creation.Request(
                email: "test@example.com",
                password: "securePass123"
            )

            let encoder = JSONEncoder()
            let data = try encoder.encode(request)

            let decoder = JSONDecoder()
            let decodedRequest = try decoder.decode(Identity.Creation.Request.self, from: data)

            #expect(decodedRequest.email == request.email)
            #expect(decodedRequest.password == request.password)
            #expect(decodedRequest == request)
        }

        @Test
        func `Verification request encoding and decoding`() throws {
            let verification = Identity.Creation.Verification(
                token: "token-456",
                email: "verify@example.com"
            )

            let encoder = JSONEncoder()
            let data = try encoder.encode(verification)

            let decoder = JSONDecoder()
            let decodedVerification = try decoder.decode(
                Identity.Creation.Verification.self,
                from: data
            )

            #expect(decodedVerification.email == verification.email)
            #expect(decodedVerification.token == verification.token)
            #expect(decodedVerification == verification)
        }
    }
}

extension Identity.Password.Change {
    @Suite
    struct Test {

        @Test
        func `Creates password reset confirmation`() {
            let confirmation = Identity.Password.Reset.Confirm(
                token: "reset-token-abc",
                newPassword: "newPassword123"
            )

            #expect(confirmation.newPassword == "newPassword123")
            #expect(confirmation.token == "reset-token-abc")
        }

        @Test
        func `Creates password change request`() {
            let changeRequest = Identity.Password.Change.Request(
                currentPassword: "current123",
                newPassword: "new456"
            )

            #expect(changeRequest.currentPassword == "current123")
            #expect(changeRequest.newPassword == "new456")
        }

        @Test
        func `Password reset confirmation encoding and decoding`() throws {
            let confirmation = Identity.Password.Reset.Confirm(
                token: "token-xyz",
                newPassword: "newSecurePass"
            )

            let encoder = JSONEncoder()
            let data = try encoder.encode(confirmation)

            let decoder = JSONDecoder()
            let decodedConfirmation = try decoder.decode(
                Identity.Password.Reset.Confirm.self,
                from: data
            )

            #expect(decodedConfirmation.newPassword == confirmation.newPassword)
            #expect(decodedConfirmation.token == confirmation.token)
            #expect(decodedConfirmation == confirmation)
        }

        @Test
        func `Password change request encoding and decoding`() throws {
            let changeRequest = Identity.Password.Change.Request(
                currentPassword: "oldPass",
                newPassword: "newPass"
            )

            let encoder = JSONEncoder()
            let data = try encoder.encode(changeRequest)

            let decoder = JSONDecoder()
            let decodedRequest = try decoder.decode(
                Identity.Password.Change.Request.self,
                from: data
            )

            #expect(decodedRequest.currentPassword == changeRequest.currentPassword)
            #expect(decodedRequest.newPassword == changeRequest.newPassword)
            #expect(decodedRequest == changeRequest)
        }
    }
}

extension Identity.Deletion {
    @Suite
    struct Test {

        @Test
        func `Creates deletion request`() {
            let request = Identity.Deletion.Request(
                reauthToken: "reauth-token-123"
            )

            #expect(request.reauthToken == "reauth-token-123")
        }

        // Test removed - Deletion.Request only has reauthToken parameter

        @Test
        func `Deletion request encoding and decoding`() throws {
            let request = Identity.Deletion.Request(
                reauthToken: "reauth-token-456"
            )

            let encoder = JSONEncoder()
            let data = try encoder.encode(request)

            let decoder = JSONDecoder()
            let decodedRequest = try decoder.decode(Identity.Deletion.Request.self, from: data)

            #expect(decodedRequest.reauthToken == request.reauthToken)
            #expect(decodedRequest == request)
        }

        // Test removed - Deletion.Request only has reauthToken parameter
    }
}

extension Identity.Reauthorization {
    @Suite
    struct Test {

        @Test
        func `Creates reauthorization request`() {
            let request = Identity.Reauthorization.Request(password: "password123")

            #expect(request.password == "password123")
        }

        @Test
        func `Reauthorization request encoding and decoding`() throws {
            let request = Identity.Reauthorization.Request(password: "securePassword")

            let encoder = JSONEncoder()
            let data = try encoder.encode(request)

            let decoder = JSONDecoder()
            let decodedRequest = try decoder.decode(
                Identity.Reauthorization.Request.self,
                from: data
            )

            #expect(decodedRequest.password == request.password)
            #expect(decodedRequest == request)
        }
    }
}

extension Identity.MFA {
    @Suite
    struct Test {

        @Test
        func `Creates TOTP setup response`() throws {
            let qrCodeURL = URL(
                string:
                    "otpauth://totp/Example:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example"
            )!
            let response = Identity.MFA.TOTP.SetupResponse(
                secret: "JBSWY3DPEHPK3PXP",
                qrCodeURL: qrCodeURL,
                manualEntryKey: "JBSW Y3DP EHPK 3PXP"
            )

            #expect(response.secret == "JBSWY3DPEHPK3PXP")
            #expect(response.qrCodeURL == qrCodeURL)
            #expect(response.manualEntryKey == "JBSW Y3DP EHPK 3PXP")
        }

        @Test
        func `TOTP setup response encoding and decoding`() throws {
            let qrCodeURL = URL(string: "otpauth://totp/Test:test@example.com")!
            let response = Identity.MFA.TOTP.SetupResponse(
                secret: "SECRET123",
                qrCodeURL: qrCodeURL,
                manualEntryKey: "SECR ET12 3"
            )

            let encoder = JSONEncoder()
            let data = try encoder.encode(response)

            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(
                Identity.MFA.TOTP.SetupResponse.self,
                from: data
            )

            #expect(decodedResponse.secret == response.secret)
            #expect(decodedResponse.qrCodeURL == response.qrCodeURL)
            #expect(decodedResponse.manualEntryKey == response.manualEntryKey)
            #expect(decodedResponse == response)
        }

        @Test
        func `Creates MFA status response`() {
            let configured = Identity.MFA.Status.ConfiguredMethods(
                totp: true,
                sms: false,
                email: true,
                webauthn: false,
                backupCodesRemaining: 5
            )
            let status = Identity.MFA.Status.Response(
                configured: configured,
                isRequired: true
            )

            #expect(status.configured.totp == true)
            #expect(status.configured.sms == false)
            #expect(status.configured.email == true)
            #expect(status.configured.webauthn == false)
            #expect(status.configured.backupCodesRemaining == 5)
            #expect(status.isRequired == true)
        }

        @Test
        func `MFA status encoding and decoding`() throws {
            let configured = Identity.MFA.Status.ConfiguredMethods(
                totp: true,
                sms: true,
                email: false,
                webauthn: true,
                backupCodesRemaining: 10
            )
            let status = Identity.MFA.Status.Response(
                configured: configured,
                isRequired: false
            )

            let encoder = JSONEncoder()
            let data = try encoder.encode(status)

            let decoder = JSONDecoder()
            let decodedStatus = try decoder.decode(Identity.MFA.Status.Response.self, from: data)

            #expect(decodedStatus.configured.totp == status.configured.totp)
            #expect(decodedStatus.configured.sms == status.configured.sms)
            #expect(decodedStatus.configured.email == status.configured.email)
            #expect(decodedStatus.configured.webauthn == status.configured.webauthn)
            #expect(
                decodedStatus.configured.backupCodesRemaining
                    == status.configured.backupCodesRemaining
            )
            #expect(decodedStatus.isRequired == status.isRequired)
            #expect(decodedStatus == status)
        }

        // WebAuthn credential response tests removed - type not found in current implementation
    }
}
