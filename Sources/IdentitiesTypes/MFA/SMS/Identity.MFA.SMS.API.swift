//
//  Identity.MFA.SMS.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import CasePaths
import Foundation
import TypesFoundation

extension Identity.MFA.SMS {
  /// SMS-based authentication operations.
  @CasePathable
  @dynamicMemberLookup
  public enum API: Equatable, Sendable {
    /// Setup SMS with phone number
    case setup(Identity.MFA.SMS.Setup)

    /// Request a new SMS code
    case requestCode

    /// Verify SMS code during authentication
    case verify(Identity.MFA.SMS.Verify)

    /// Update phone number
    case updatePhoneNumber(Identity.MFA.SMS.UpdatePhoneNumber)

    /// Disable SMS authentication
    case disable(Identity.MFA.DisableRequest)
  }
}

extension Identity.MFA.SMS.API {
  /// Router for SMS endpoints.
  public struct Router: ParserPrinter, Sendable {

    public init() {}

    public var body: some URLRouting.Router<Identity.MFA.SMS.API> {
      OneOf {
        URLRouting.Route(.case(Identity.MFA.SMS.API.setup)) {
          Method.post
          Path.setup
          Body(.json(Identity.MFA.SMS.Setup.self))
        }

        URLRouting.Route(.case(Identity.MFA.SMS.API.requestCode)) {
          Method.post
          Path { "request" }
        }

        URLRouting.Route(.case(Identity.MFA.SMS.API.verify)) {
          Method.post
          Path.verify
          Body(.json(Identity.MFA.SMS.Verify.self))
        }

        URLRouting.Route(.case(Identity.MFA.SMS.API.updatePhoneNumber)) {
          Method.post
          Path.update
          Body(.json(Identity.MFA.SMS.UpdatePhoneNumber.self))
        }

        URLRouting.Route(.case(Identity.MFA.SMS.API.disable)) {
          Method.post
          Path.disable
          Body(.json(Identity.MFA.DisableRequest.self))
        }
      }
    }
  }
}
