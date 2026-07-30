//
//  Identity Simple Router Tests.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 20/02/2025.
//

import Dependencies
import Dependencies_Test_Support
import EmailAddress
import Foundation
import Testing

@testable import IdentitiesTypes

extension Identity.API.Router {
    @Suite
    struct Test {

        let router: Identity.API.Router = .init()

        @Test
        func `Creates correct URL for authenticate credentials`() throws {
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
            #expect(
                Identity.API.cases.authenticate.credentials.extract(match)?.username
                    == "user@example.com"
            )
            #expect(
                Identity.API.cases.authenticate.credentials.extract(match)?.password
                    == "password123"
            )
        }

        @Test
        func `Creates correct URL for logout`() throws {
            let api: Identity.API = .logout(.current)

            let request = try router.request(for: api)
            #expect(request.url?.path == "/logout")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.logout.current))
        }
    }
}
