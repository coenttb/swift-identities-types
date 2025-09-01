//
//  Identity.API.MFA.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import CasePaths
import Foundation
import ServerFoundation

extension Identity.API {
    /// Multi-factor authentication API endpoints.
    ///
    /// The `MFA` API provides endpoints for managing various MFA methods:
    /// - TOTP (Time-based One-Time Password)
    /// - SMS verification
    /// - Email verification
    /// - WebAuthn/FIDO2
    /// - Backup codes
    /// - General MFA status
    ///
    /// Each MFA method can be independently configured and used.
    @CasePathable
    @dynamicMemberLookup
    public enum MFA: Equatable, Sendable {
        /// TOTP-based authentication operations
        case totp(Identity.API.MFA.TOTP)
        
        /// SMS-based authentication operations
        case sms(Identity.API.MFA.SMS)
        
        /// Email-based authentication operations
        case email(Identity.API.MFA.Email)
        
        /// WebAuthn/FIDO2 authentication operations
        case webauthn(Identity.API.MFA.WebAuthn)
        
        /// Backup code operations
        case backupCodes(Identity.API.MFA.BackupCodes)
        
        /// General MFA status operations
        case status(Identity.API.MFA.Status)
        
        /// General MFA verification (handles session token verification)
        case verify(Identity.API.MFA.Verify)
    }
}

extension Identity.API.MFA {
    /// Router for MFA API endpoints.
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}
        
        public var body: some URLRouting.Router<Identity.API.MFA> {
            OneOf {
                URLRouting.Route(.case(Identity.API.MFA.totp)) {
                    Path { "totp" }
                    TOTP.Router()
                }
                
                URLRouting.Route(.case(Identity.API.MFA.sms)) {
                    Path { "sms" }
                    SMS.Router()
                }
                
                URLRouting.Route(.case(Identity.API.MFA.email)) {
                    Path { "email" }
                    Email.Router()
                }
                
                URLRouting.Route(.case(Identity.API.MFA.webauthn)) {
                    Path { "webauthn" }
                    WebAuthn.Router()
                }
                
                URLRouting.Route(.case(Identity.API.MFA.backupCodes)) {
                    Path { "backup-codes" }
                    BackupCodes.Router()
                }
                
                URLRouting.Route(.case(Identity.API.MFA.status)) {
                    Path { "status" }
                    Status.Router()
                }
                
                URLRouting.Route(.case(Identity.API.MFA.verify)) {
                    Path { "verify" }
                    Verify.Router()
                }
            }
        }
    }
}