//
//  Identity Model Tests.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 20/02/2025.
//

import Dependencies
import DependenciesTestSupport
import EmailAddress
import Foundation
@testable import IdentitiesTypes
import Testing

@Suite("Identity Creation Model Tests")
struct IdentityCreationModelTests {
    
    @Test("Creates identity creation request")
    func testCreationRequestModel() {
        let request = Identity.Creation.Request(
            email: "new@example.com",
            password: "password123"
        )
        
        #expect(request.email == "new@example.com")
        #expect(request.password == "password123")
    }
    
    @Test("Creates identity verification request")
    func testVerificationRequestModel() {
        let verification = Identity.Creation.Verification(
            token: "verification-token-123",
            email: "verify@example.com"
        )
        
        #expect(verification.email == "verify@example.com")
        #expect(verification.token == "verification-token-123")
    }
    
    @Test("Creation request encoding and decoding")
    func testCreationRequestCodable() throws {
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
    
    @Test("Verification request encoding and decoding")
    func testVerificationCodable() throws {
        let verification = Identity.Creation.Verification(
            token: "token-456",
            email: "verify@example.com"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(verification)
        
        let decoder = JSONDecoder()
        let decodedVerification = try decoder.decode(Identity.Creation.Verification.self, from: data)
        
        #expect(decodedVerification.email == verification.email)
        #expect(decodedVerification.token == verification.token)
        #expect(decodedVerification == verification)
    }
}

@Suite("Identity Password Model Tests")
struct IdentityPasswordModelTests {
    
    @Test("Creates password reset confirmation")
    func testPasswordResetConfirmation() {
        let confirmation = Identity.Password.Reset.Confirm(
            token: "reset-token-abc",
            newPassword: "newPassword123"
        )
        
        #expect(confirmation.newPassword == "newPassword123")
        #expect(confirmation.token == "reset-token-abc")
    }
    
    @Test("Creates password change request")
    func testPasswordChangeRequest() {
        let changeRequest = Identity.Password.Change.Request(
            currentPassword: "current123",
            newPassword: "new456"
        )
        
        #expect(changeRequest.currentPassword == "current123")
        #expect(changeRequest.newPassword == "new456")
    }
    
    @Test("Password reset confirmation encoding and decoding")
    func testPasswordResetConfirmationCodable() throws {
        let confirmation = Identity.Password.Reset.Confirm(
            token: "token-xyz",
            newPassword: "newSecurePass"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(confirmation)
        
        let decoder = JSONDecoder()
        let decodedConfirmation = try decoder.decode(Identity.Password.Reset.Confirm.self, from: data)
        
        #expect(decodedConfirmation.newPassword == confirmation.newPassword)
        #expect(decodedConfirmation.token == confirmation.token)
        #expect(decodedConfirmation == confirmation)
    }
    
    @Test("Password change request encoding and decoding")
    func testPasswordChangeRequestCodable() throws {
        let changeRequest = Identity.Password.Change.Request(
            currentPassword: "oldPass",
            newPassword: "newPass"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(changeRequest)
        
        let decoder = JSONDecoder()
        let decodedRequest = try decoder.decode(Identity.Password.Change.Request.self, from: data)
        
        #expect(decodedRequest.currentPassword == changeRequest.currentPassword)
        #expect(decodedRequest.newPassword == changeRequest.newPassword)
        #expect(decodedRequest == changeRequest)
    }
}

@Suite("Identity Deletion Model Tests")
struct IdentityDeletionModelTests {
    
    @Test("Creates deletion request")
    func testDeletionRequest() {
        let request = Identity.Deletion.Request(
            reauthToken: "reauth-token-123"
        )
        
        #expect(request.reauthToken == "reauth-token-123")
    }
    
    // Test removed - Deletion.Request only has reauthToken parameter
    
    @Test("Deletion request encoding and decoding")
    func testDeletionRequestCodable() throws {
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

@Suite("Identity Reauthorization Model Tests")
struct IdentityReauthorizationModelTests {
    
    @Test("Creates reauthorization request")
    func testReauthorizationRequest() {
        let request = Identity.Reauthorization.Request(password: "password123")
        
        #expect(request.password == "password123")
    }
    
    @Test("Reauthorization request encoding and decoding")
    func testReauthorizationCodable() throws {
        let request = Identity.Reauthorization.Request(password: "securePassword")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        
        let decoder = JSONDecoder()
        let decodedRequest = try decoder.decode(Identity.Reauthorization.Request.self, from: data)
        
        #expect(decodedRequest.password == request.password)
        #expect(decodedRequest == request)
    }
}

@Suite("Identity MFA Model Tests")
struct IdentityMFAModelTests {
    
    @Test("Creates TOTP setup response")
    func testTOTPSetupResponse() throws {
        let qrCodeURL = URL(string: "otpauth://totp/Example:user@example.com?secret=JBSWY3DPEHPK3PXP&issuer=Example")!
        let response = Identity.MFA.TOTP.SetupResponse(
            secret: "JBSWY3DPEHPK3PXP",
            qrCodeURL: qrCodeURL,
            manualEntryKey: "JBSW Y3DP EHPK 3PXP"
        )
        
        #expect(response.secret == "JBSWY3DPEHPK3PXP")
        #expect(response.qrCodeURL == qrCodeURL)
        #expect(response.manualEntryKey == "JBSW Y3DP EHPK 3PXP")
    }
    
    @Test("TOTP setup response encoding and decoding")
    func testTOTPSetupResponseCodable() throws {
        let qrCodeURL = URL(string: "otpauth://totp/Test:test@example.com")!
        let response = Identity.MFA.TOTP.SetupResponse(
            secret: "SECRET123",
            qrCodeURL: qrCodeURL,
            manualEntryKey: "SECR ET12 3"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(response)
        
        let decoder = JSONDecoder()
        let decodedResponse = try decoder.decode(Identity.MFA.TOTP.SetupResponse.self, from: data)
        
        #expect(decodedResponse.secret == response.secret)
        #expect(decodedResponse.qrCodeURL == response.qrCodeURL)
        #expect(decodedResponse.manualEntryKey == response.manualEntryKey)
        #expect(decodedResponse == response)
    }
    
    @Test("Creates MFA status response")
    func testMFAStatusResponse() {
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
    
    @Test("MFA status encoding and decoding")
    func testMFAStatusCodable() throws {
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
        #expect(decodedStatus.configured.backupCodesRemaining == status.configured.backupCodesRemaining)
        #expect(decodedStatus.isRequired == status.isRequired)
        #expect(decodedStatus == status)
    }
    
    // WebAuthn credential response tests removed - type not found in current implementation
}
