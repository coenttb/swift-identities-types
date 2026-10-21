//
//  Identity.MFA.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Case_Macro
import Coder
import Foundation
import HTTP
import HTTP_Router

extension Identity.MFA {
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
    @Prisms
    @Folds
    @Cases
    public enum API: Equatable, Sendable {
        /// TOTP-based authentication operations
        case totp(Identity.MFA.TOTP.API)

        /// SMS-based authentication operations
        case sms(Identity.MFA.SMS.API)

        /// Email-based authentication operations
        case email(Identity.MFA.Email.API)

        /// WebAuthn/FIDO2 authentication operations
        case webauthn(Identity.MFA.WebAuthn.API)

        /// Backup code operations
        case backupCodes(Identity.MFA.BackupCodes.API)

        /// General MFA status operations
        case status(Identity.MFA.Status.API)

        /// General MFA verification (handles session token verification)
        case verify(Identity.MFA.Verify)
    }
}

extension Identity.MFA.API: HTTP.Routable {
    /// Router for MFA API endpoints.
    public static var router: some HTTP.Router.`Protocol`<Identity.MFA.API> {
        Coder::Case(
            Identity.MFA.API.cases.totp.prism,
            Identity.MFA.API.cases.totp.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("totp")
            Identity.MFA.TOTP.API.router
        }

        Coder::Case(
            Identity.MFA.API.cases.sms.prism,
            Identity.MFA.API.cases.sms.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("sms")
            Identity.MFA.SMS.API.router
        }

        Coder::Case(
            Identity.MFA.API.cases.email.prism,
            Identity.MFA.API.cases.email.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("email")
            Identity.MFA.Email.API.router
        }

        Coder::Case(
            Identity.MFA.API.cases.webauthn.prism,
            Identity.MFA.API.cases.webauthn.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("webauthn")
            Identity.MFA.WebAuthn.API.router
        }

        Coder::Case(
            Identity.MFA.API.cases.backupCodes.prism,
            Identity.MFA.API.cases.backupCodes.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("backup-codes")
            Identity.MFA.BackupCodes.API.router
        }

        Coder::Case(
            Identity.MFA.API.cases.status.prism,
            Identity.MFA.API.cases.status.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("status")
            Identity.MFA.Status.API.router
        }

        Coder::Case(
            Identity.MFA.API.cases.verify.prism,
            Identity.MFA.API.cases.verify.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("verify")
            Identity.MFA.Verify.router
        }
    }
}
