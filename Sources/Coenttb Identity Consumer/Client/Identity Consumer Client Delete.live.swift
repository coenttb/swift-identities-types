//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 11/02/2025.
//

import Coenttb_Web
import Identity_Shared
import Dependencies
import EmailAddress
import Identity_Consumer
import Coenttb_Identity_Shared
import Coenttb_Vapor
import RateLimiter
import JWT

extension Identity.Consumer.Client.Delete {
    package static func live(
        provider: Identity.Consumer.Client.Live.Provider,
        router: AnyParserPrinter<URLRequestData, Identity.Consumer.API>,
        makeRequest: @escaping (AnyParserPrinter<URLRequestData, Identity.Consumer.API>) -> (_ route: Identity.Consumer.API) throws -> URLRequest = Identity.Consumer.Client.Live.makeRequest
    ) -> Self {
        return .init(
            request: { reauthToken in
                let route: Identity.Consumer.API = .delete(.request(.init(reauthToken: reauthToken)))
                let router = try Identity.Consumer.API.Router.prepare(baseRouter: router, baseURL: provider.baseURL, route: route)

                @Dependency(URLRequest.Handler.self) var handleRequest
                
                do {
                    try await handleRequest(for: makeRequest(router)(route))
                } catch {
                    throw Abort(.unauthorized)
                }
            },
            cancel: {
                let route: Identity.Consumer.API = .delete(.cancel)
                let router = try Identity.Consumer.API.Router.prepare(baseRouter: router, baseURL: provider.baseURL, route: route)

                @Dependency(URLRequest.Handler.self) var handleRequest

                do {
                    try await handleRequest(for: makeRequest(router)(route))
                } catch {
                    throw Abort(.unauthorized)
                }
            },
            confirm: {
                let route: Identity.Consumer.API = .delete(.confirm)
                let router = try Identity.Consumer.API.Router.prepare(baseRouter: router, baseURL: provider.baseURL, route: route)
                
                @Dependency(URLRequest.Handler.self) var handleRequest

                do {
                    try await handleRequest(for: makeRequest(router)(route))
                } catch {
                    throw Abort(.unauthorized)
                }
            }
        )
    }
}
