//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 11/02/2025.
//

import Coenttb_Identity_Shared
import Coenttb_Vapor
import Coenttb_Web
import Dependencies
import EmailAddress
import Identity_Consumer
import Identity_Shared
import JWT
import RateLimiter

extension Identity.Consumer.Client.EmailChange {
    package static func live(
        router: AnyParserPrinter<URLRequestData, Identity.Consumer.API>,
        makeRequest: @escaping (AnyParserPrinter<URLRequestData, Identity.Consumer.API>) -> (_ route: Identity.Consumer.API) throws -> URLRequest = Identity.Consumer.Client.makeRequest
    ) -> Self {
        
        
        return .init(
            request: { newEmail in
                guard let newEmail = newEmail?.rawValue else {
                    throw Abort(.conflict, reason: "Email address cannot be nil")
                }

                let route: Identity.Consumer.API = .emailChange(.request(.init(newEmail: newEmail)))
                let router = try Identity.Consumer.API.Router.prepare(baseRouter: router, route: route)

                @Dependency(URLRequest.Handler.self) var handleRequest

                do {
                    return try await handleRequest(
                        for: makeRequest(router)(route),
                        decodingTo: Identity.EmailChange.Request.Result.self
                    )
                } catch {
                    throw Abort(.unauthorized)
                }
            },
            confirm: { token in
                let route: Identity.Consumer.API = .emailChange(.confirm(.init(token: token)))
                let router = try Identity.Consumer.API.Router.prepare(baseRouter: router, route: route)

                @Dependency(URLRequest.Handler.self) var handleRequest

                do {
                    return try await handleRequest(
                        for: makeRequest(router)(route),
                        decodingTo: Identity.EmailChange.Confirm.Response.self
                    )
                    
                } catch {
                    throw Abort(.internalServerError)
                }
            }
        )
    }
}
