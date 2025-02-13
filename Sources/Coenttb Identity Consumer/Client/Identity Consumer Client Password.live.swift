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

extension Identity.Consumer.Client.Password {
    package static func live(
        provider: Identity.Consumer.Client.Live.Provider,
        router: AnyParserPrinter<URLRequestData, Identity.Consumer.API>,
        makeRequest: @escaping (AnyParserPrinter<URLRequestData, Identity.Consumer.API>) -> (_ route: Identity.Consumer.API) throws -> URLRequest = Identity.Consumer.Client.Live.makeRequest
    ) -> Self {
        return .init(
            reset: .init(
                request: { email in
                    let route: Identity.Consumer.API = .password(.reset(.request(.init(email: email))))
                    let router = try Identity.Consumer.API.Router.prepare(baseRouter: router, baseURL: provider.baseURL, route: route)

                    @Dependency(URLRequest.Handler.self) var handleRequest

                    do {
                        try await handleRequest(for: makeRequest(router)(route))
                    } catch {
                        throw Abort(.unauthorized)
                    }
                },
                confirm: { token, newPassword in
                    let route: Identity.Consumer.API = .password(.reset(.confirm(.init(token: token, newPassword: newPassword))))
                    let router = try Identity.Consumer.API.Router.prepare(baseRouter: router, baseURL: provider.baseURL, route: route)

                    @Dependency(URLRequest.Handler.self) var handleRequest

                    do {
                        try await handleRequest(for: makeRequest(router)(route))
                    } catch {
                        throw Abort(.internalServerError)
                    }
                }
            ),
            change: .init(
                request: { currentPassword, newPassword in
                    let route: Identity.Consumer.API = .password(.change(.request(change: .init(currentPassword: currentPassword, newPassword: newPassword))))
                    let router = try Identity.Consumer.API.Router.prepare(baseRouter: router, baseURL: provider.baseURL, route: route)

                    @Dependency(URLRequest.Handler.self) var handleRequest

                    do {
                        try await handleRequest(for: makeRequest(router)(route))
                    } catch {
                        throw Abort(.unauthorized)
                    }
                }
            )
        )
    }
}
