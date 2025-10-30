//
//  Identity.Reauthorization+TestDependencyKey.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Dependencies
import JWT

extension Identity.Reauthorization: TestDependencyKey {
  public static var testValue: Self {
    return Self(
      client: .init(
        reauthorize: { password in
          // Create a test JWT token for reauthorization
          return try .parse(from: "test-reauth-token-\(password)")
        }
      ),
      router: Identity.Reauthorization.Route.Router()
    )
  }
}
