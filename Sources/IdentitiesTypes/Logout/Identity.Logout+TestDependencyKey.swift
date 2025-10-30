//
//  Identity.Logout+TestDependencyKey.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Dependencies

extension Identity.Logout: TestDependencyKey {
  public static var testValue: Self {
    @Dependency(Identity._TestDatabase.self) var database

    return Self(
      client: .init(
        current: {
          await database.reset()
        },
        all: {
          await database.reset()
        }
      ),
      router: Identity.Logout.Route.Router()
    )
  }
}
