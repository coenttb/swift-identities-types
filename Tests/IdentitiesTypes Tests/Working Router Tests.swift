//
//  Working Router Test.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 20/02/2025.
//

import Testing

@testable import IdentitiesTypes

@Suite
struct `Working Router Test` {

    @Test
    func `Basic router test`() throws {
        let router = Identity.API.self

        // Create a simple API request
        let api: Identity.API = .logout(.current)

        // Get URLRequest from router
        let request = try router.request(for: api)

        // Check URL path
        #expect(request.path == "/logout")

        // Check method
        #expect(request.method.rawValue == "POST")

        // Round-trip test
        let match = try router.match(request: request)
        #expect({ if case .logout(.current) = match { true } else { false } }())
    }
}
