//
//  Identity.Email+TestDependencyKey.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Dependencies
import EmailAddress

extension Identity.Email: TestDependencyKey {
  public static var testValue: Self {
    return Self(
      change: .testValue
    )
  }
}

extension Identity.Email.Change: TestDependencyKey {
  public static var testValue: Self {
    @Dependency(Identity._TestDatabase.self) var database

    return Self(
      client: .init(
        request: { newEmail in
          _ = try EmailAddress(newEmail)
          guard let currentEmail = await database.currentUser else {
            throw Identity._TestDatabase.TestError.userNotFound
          }
          _ = try await database.initiateEmailChange(currentEmail: currentEmail, newEmail: newEmail)
          return .success
        },
        confirm: { token in
          guard let email = await database.currentUser else {
            throw Identity._TestDatabase.TestError.userNotFound
          }
          let session = try await database.confirmEmailChange(email: email, token: token)

          return .init(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken
          )
        }
      ),
      router: Identity.Email.Change.API.Router()
    )
  }
}
