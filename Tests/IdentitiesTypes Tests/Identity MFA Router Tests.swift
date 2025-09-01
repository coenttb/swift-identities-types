//
//  Identity MFA Router Tests Fixed.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 20/02/2025.
//

import Authenticating
import Dependencies
import DependenciesTestSupport
import EmailAddress
import Foundation
@testable import Identities
import Testing
import URLRouting

@Suite("Identity MFA Router Tests")
struct MFARouterTests {
    
    let router: Identity.API.MFA.Router = .init()
    
    @Test("Creates correct URL for MFA status configured check")
    func testMFAStatusConfiguredURL() throws {
        let mfa: Identity.API.MFA = .status(.configured)
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/status/configured")
        #expect(request.httpMethod == "GET")
        
        let match = try router.match(request: request)
        #expect(match.is(\.status.configured))
    }
    
    @Test("Creates correct URL for MFA status required check")
    func testMFAStatusRequiredURL() throws {
        let mfa: Identity.API.MFA = .status(.isRequired)
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/status/required")
        #expect(request.httpMethod == "GET")
        
        let match = try router.match(request: request)
        #expect(match.is(\.status.isRequired))
    }
    
    @Test("Creates correct URL for MFA TOTP setup")
    func testMFATOTPSetupURL() throws {
        let mfa: Identity.API.MFA = .totp(.setup)
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/totp/setup")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.totp.setup))
    }
    
    @Test("Creates correct URL for MFA TOTP verification")
    func testMFATOTPVerifyURL() throws {
        let verifyRequest = Identity.MFA.TOTP.Verify(code: "123456", sessionToken: "session-token")
        let mfa: Identity.API.MFA = .totp(.verify(verifyRequest))
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/totp/verify")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.totp.verify))
        #expect(match.totp?.verify?.code == "123456")
    }
    
    @Test("Creates correct URL for MFA TOTP disable")
    func testMFATOTPDisableURL() throws {
        let disableRequest = Identity.MFA.DisableRequest(reauthorizationToken: "reauth-token")
        let mfa: Identity.API.MFA = .totp(.disable(disableRequest))
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/totp/disable")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.totp.disable))
    }
    
    @Test("Creates correct URL for MFA SMS setup")
    func testMFASMSSetupURL() throws {
        let setupRequest = Identity.MFA.SMS.Setup(phoneNumber: "+1234567890")
        let mfa: Identity.API.MFA = .sms(.setup(setupRequest))
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/sms/setup")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.sms.setup))
        #expect(match.sms?.setup?.phoneNumber == "+1234567890")
    }
    
    @Test("Creates correct URL for MFA SMS verification")
    func testMFASMSVerifyURL() throws {
        let verifyRequest = Identity.MFA.SMS.Verify(code: "123456", sessionToken: "session-token")
        let mfa: Identity.API.MFA = .sms(.verify(verifyRequest))
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/sms/verify")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.sms.verify))
        #expect(match.sms?.verify?.code == "123456")
    }
    
    @Test("Creates correct URL for MFA SMS request code")
    func testMFASMSRequestCodeURL() throws {
        let mfa: Identity.API.MFA = .sms(.requestCode)
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/sms/request")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.sms.requestCode))
    }
    
    @Test("Creates correct URL for MFA SMS disable")
    func testMFASMSDisableURL() throws {
        let disableRequest = Identity.MFA.DisableRequest(reauthorizationToken: "reauth-token")
        let mfa: Identity.API.MFA = .sms(.disable(disableRequest))
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/sms/disable")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.sms.disable))
    }
    
    @Test("Creates correct URL for MFA Email setup")
    func testMFAEmailSetupURL() throws {
        let setupRequest = Identity.MFA.Email.Setup(email: "mfa@example.com")
        let mfa: Identity.API.MFA = .email(.setup(setupRequest))
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/email/setup")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.email.setup))
        #expect(match.email?.setup?.email == "mfa@example.com")
    }
    
    @Test("Creates correct URL for MFA Email verification")
    func testMFAEmailVerifyURL() throws {
        let verifyRequest = Identity.MFA.Email.Verify(code: "123456", sessionToken: "session-token")
        let mfa: Identity.API.MFA = .email(.verify(verifyRequest))
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/email/verify")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.email.verify))
        #expect(match.email?.verify?.code == "123456")
    }
    
    @Test("Creates correct URL for MFA Email request code")
    func testMFAEmailRequestCodeURL() throws {
        let mfa: Identity.API.MFA = .email(.requestCode)
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/email/request")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.email.requestCode))
    }
    
    @Test("Creates correct URL for MFA Email disable")
    func testMFAEmailDisableURL() throws {
        let disableRequest = Identity.MFA.DisableRequest(reauthorizationToken: "reauth-token")
        let mfa: Identity.API.MFA = .email(.disable(disableRequest))
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/email/disable")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.email.disable))
    }
    
    @Test("Creates correct URL for MFA Backup Codes regenerate")
    func testMFABackupCodesRegenerateURL() throws {
        let mfa: Identity.API.MFA = .backupCodes(.regenerate)
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/backup-codes/regenerate")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.backupCodes.regenerate))
    }
    
    @Test("Creates correct URL for MFA Backup Codes verify")
    func testMFABackupCodesVerifyURL() throws {
        let verifyRequest = Identity.MFA.BackupCodes.Verify(code: "backup-code-123", sessionToken: "session-token")
        let mfa: Identity.API.MFA = .backupCodes(.verify(verifyRequest))
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/backup-codes/verify")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.backupCodes.verify))
        #expect(match.backupCodes?.verify?.code == "backup-code-123")
    }
    
    @Test("Creates correct URL for MFA WebAuthn begin registration")
    func testMFAWebAuthnBeginRegistrationURL() throws {
        let mfa: Identity.API.MFA = .webauthn(.beginRegistration)
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/webauthn/register/begin")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.webauthn.beginRegistration))
    }
    
    @Test("Creates correct URL for MFA WebAuthn disable")
    func testMFAWebAuthnDisableURL() throws {
        let disableRequest = Identity.MFA.DisableRequest(reauthorizationToken: "reauth-token")
        let mfa: Identity.API.MFA = .webauthn(.disable(disableRequest))
        
        let request = try router.request(for: mfa)
        #expect(request.url?.path == "/webauthn/disable")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.webauthn.disable))
    }
}