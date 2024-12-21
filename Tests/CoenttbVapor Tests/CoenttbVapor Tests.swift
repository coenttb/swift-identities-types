//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 13/12/2024.
//

import Foundation
import Testing
@testable import CoenttbVapor

@Test
func testCanonicalHostMiddleware() async throws  {
    // Create an instance of the Application
    let app = try await Application.make(.testing)
    

    
    // Configure the application with test parameters
    try await Application.configure(
        app: app,
        httpsRedirect: nil,
        canonicalHost: "https://coenttb.com",
        allowedInsecureHosts: nil,
        baseUrl: URL(string: "https://coenttb.com")!
    )


    let request = Request(
        application: app,
        method: .GET,
        url: URI(string: "https://coenttb.com"),
        on: app.eventLoopGroup.next()
    )

    // Use a TestResponder to capture the middleware's response
    let response = app.responder.respond(to: request)

    
    try await app.asyncShutdown()
}
