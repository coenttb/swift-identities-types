//
//  Identity.MFA.TOTP.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import CasePaths
import Foundation
import TypesFoundation

extension Identity.MFA.TOTP {
  /// TOTP (Time-based One-Time Password) operations.
  ///
  /// Supports authenticator apps like Google Authenticator, Authy, etc.
  @CasePathable
  @dynamicMemberLookup
  public enum API: Equatable, Sendable {
    /// Initialize TOTP setup (returns secret and QR code)
    case setup

    /// Confirm TOTP setup with verification code
    case confirmSetup(Identity.MFA.TOTP.ConfirmSetup)

    /// Verify TOTP code during authentication
    case verify(Identity.MFA.TOTP.Verify)

    /// Disable TOTP authentication
    case disable(Identity.MFA.DisableRequest)

    public static let confirmSetup: Self = .confirmSetup(.init(code: ""))
  }
}

extension Identity.MFA.TOTP.API {
  /// Router for TOTP endpoints.
  public struct Router: ParserPrinter, Sendable {

    public init() {}

    public var body: some URLRouting.Router<Identity.MFA.TOTP.API> {
      OneOf {
        URLRouting.Route(.case(Identity.MFA.TOTP.API.setup)) {
          Method.post
          Path.setup
        }

        URLRouting.Route(.case(Identity.MFA.TOTP.API.confirmSetup)) {
          Method.post
          Path.confirm
          Body(.form(Identity.MFA.TOTP.ConfirmSetup.self, decoder: .identities))
        }

        URLRouting.Route(.case(Identity.MFA.TOTP.API.verify)) {
          Method.post
          Path.verify
          Body(.json(Identity.MFA.TOTP.Verify.self))
        }

        URLRouting.Route(.case(Identity.MFA.TOTP.API.disable)) {
          Method.post
          Path.disable
          Body(.json(Identity.MFA.DisableRequest.self))
        }
      }
    }
  }
}
