//
//  Identity.Logout.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2025.
//

import TypesFoundation

extension Identity {
  /// Namespace for logout functionality.
  ///
  /// Logout handles the termination of user sessions and clearing of authentication tokens.
  public struct Logout: @unchecked Sendable {
    public var client: Identity.Logout.Client
    public var router: any URLRouting.Router<Identity.Logout.Route>

    public init(
      client: Identity.Logout.Client,
      router: any URLRouting.Router<Identity.Logout.Route> = Identity.Logout.Route.Router()
    ) {
      self.client = client
      self.router = router
    }
  }
}
