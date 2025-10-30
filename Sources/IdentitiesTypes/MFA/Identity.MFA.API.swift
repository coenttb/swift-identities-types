//
//  Identity.MFA.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import CasePaths
import Foundation
import TypesFoundation

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
  @CasePathable
  @dynamicMemberLookup
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

extension Identity.MFA.API {
  /// Router for MFA API endpoints.
  public struct Router: ParserPrinter, Sendable {

    public init() {}

    public var body: some URLRouting.Router<Identity.MFA.API> {
      OneOf {
        URLRouting.Route(.case(Identity.MFA.API.totp)) {
          Path { "totp" }
          Identity.MFA.TOTP.API.Router()
        }

        URLRouting.Route(.case(Identity.MFA.API.sms)) {
          Path { "sms" }
          Identity.MFA.SMS.API.Router()
        }

        URLRouting.Route(.case(Identity.MFA.API.email)) {
          Path { "email" }
          Identity.MFA.Email.API.Router()
        }

        URLRouting.Route(.case(Identity.MFA.API.webauthn)) {
          Path { "webauthn" }
          Identity.MFA.WebAuthn.API.Router()
        }

        URLRouting.Route(.case(Identity.MFA.API.backupCodes)) {
          Path { "backup-codes" }
          Identity.MFA.BackupCodes.API.Router()
        }

        URLRouting.Route(.case(Identity.MFA.API.status)) {
          Path { "status" }
          Identity.MFA.Status.API.Router()
        }

        URLRouting.Route(.case(Identity.MFA.API.verify)) {
          Path { "verify" }
          Identity.MFA.Verify.Router()
        }
      }
    }
  }
}
