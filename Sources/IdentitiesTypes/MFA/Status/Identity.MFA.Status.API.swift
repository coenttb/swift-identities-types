//
//  Identity.MFA.Status.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import CasePaths
import Foundation
import TypesFoundation

extension Identity.MFA.Status {
  /// General MFA status operations.
  @CasePathable
  @dynamicMemberLookup
  public enum API: Equatable, Sendable {
    /// Get the current MFA status including configured methods and requirements
    case get

    /// Get MFA challenge after authentication
    case challenge
  }
}

extension Identity.MFA.Status.API {
  /// Router for Status endpoints.
  public struct Router: ParserPrinter, Sendable {

    public init() {}

    public var body: some URLRouting.Router<Identity.MFA.Status.API> {
      OneOf {
        URLRouting.Route(.case(Identity.MFA.Status.API.get)) {
          Method.get
        }

        URLRouting.Route(.case(Identity.MFA.Status.API.challenge)) {
          Method.get
          Path.challenge
        }
      }
    }
  }
}
