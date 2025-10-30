//
//  Identity Simple Router Tests.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 20/02/2025.
//

import Authenticating
import Dependencies
import DependenciesTestSupport
import EmailAddress
import Foundation
import Testing

@testable import IdentitiesTypes

@Suite("Simple Identity API Router Tests")
struct SimpleIdentityAPIRouterTests {

  let router: Identity.API.Router = .init()

  @Test("Creates correct URL for authenticate credentials")
  func testAuthenticateCredentialsURL() throws {
    let api: Identity.API = .authenticate(
      .credentials(
        .init(username: "user@example.com", password: "password123")
      )
    )

    let request = try router.request(for: api)
    #expect(request.url?.path == "/authenticate")
    #expect(request.httpMethod == "POST")

    // Round-trip test
    let match = try router.match(request: request)
    #expect(match.is(\.authenticate.credentials))
    #expect(match.authenticate?.credentials?.username == "user@example.com")
    #expect(match.authenticate?.credentials?.password == "password123")
  }

  @Test("Creates correct URL for logout")
  func testLogoutURL() throws {
    let api: Identity.API = .logout(.current)

    let request = try router.request(for: api)
    #expect(request.url?.path == "/logout")
    #expect(request.httpMethod == "POST")

    let match = try router.match(request: request)
    #expect(match.is(\.logout.current))
  }
}
