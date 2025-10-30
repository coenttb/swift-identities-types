//
//  Identity.Email.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 18/02/2025.
//

import TypesFoundation

extension Identity {
  /// Namespace for email-related functionality within the Identity system.
  public struct Email: @unchecked Sendable {
    public var change: Identity.Email.Change
    public var router: any URLRouting.Router<Identity.Email.Route>

    public init(
      change: Identity.Email.Change,
      router: any URLRouting.Router<Identity.Email.Route> = Identity.Email.Route.Router()
    ) {
      self.change = change
      self.router = router
    }
  }
}
