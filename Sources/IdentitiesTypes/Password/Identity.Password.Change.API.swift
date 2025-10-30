//
//  Identity.Password.Change.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import CasePaths
import TypesFoundation

extension Identity.Password.Change {
  /// Password change API endpoints for authenticated users.
  @CasePathable
  @dynamicMemberLookup
  public enum API: Equatable, Sendable {
    /// Request a password change (requires current password)
    case request(Identity.Password.Change.Request)
  }
}

extension Identity.Password.Change.API {
  /// Router for password change endpoints.
  public struct Router: ParserPrinter, Sendable {

    public init() {}

    public var body: some URLRouting.Router<Identity.Password.Change.API> {
      URLRouting.Route(.case(Identity.Password.Change.API.request)) {
        Identity.Password.Change.Request.Router()
      }
    }
  }
}
