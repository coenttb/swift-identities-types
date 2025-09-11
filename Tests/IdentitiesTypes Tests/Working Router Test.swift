//
//  Working Router Test.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 20/02/2025.
//

import Authenticating
import Foundation
@testable import IdentitiesTypes
import Testing

@Suite("Working Router Test")
struct WorkingRouterTest {
    
    @Test("Basic router test")
    func testBasicRouter() throws {
        let router = Identity.API.Router()
        
        // Create a simple API request
        let api: Identity.API = .logout(.current)
        
        // Get URLRequest from router
        let request = try router.request(for: api)
        
        // Check URL path
        #expect(request.url?.path == "/logout")
        
        // Check method
        #expect(request.httpMethod == "POST")
        
        // Round-trip test
        let match = try router.match(request: request)
        #expect(match.is(\.logout.current))
    }
}
