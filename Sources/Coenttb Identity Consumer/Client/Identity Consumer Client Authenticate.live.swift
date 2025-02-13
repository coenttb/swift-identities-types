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

extension Identity.Consumer.Client.Authenticate {
    package static func live(
        provider: Identity.Consumer.Client.Live.Provider,
        router: AnyParserPrinter<URLRequestData, Identity.Consumer.API>,
        makeRequest: @escaping (AnyParserPrinter<URLRequestData, Identity.Consumer.API>) -> (_ route: Identity.Consumer.API) throws -> URLRequest = Identity.Consumer.Client.Live.makeRequest
    ) -> Self {
        return .init(
            credentials: { username, password in
                let route: Identity.Consumer.API = .authenticate(.credentials(.init(email: username, password: password)))
                let router = try Identity.Consumer.API.Router.prepare(baseRouter: router, baseURL: provider.baseURL, route: route)

                @Dependency(URLRequest.Handler.self) var handleRequest

                do {
                    let response = try await handleRequest(
                        for: makeRequest(router)(route),
                        decodingTo: Identity.Authentication.Response.self
                    )

                    @Dependency(\.request) var request
                    guard let request else { throw Abort.requestUnavailable }

                    let accessToken = try await request.jwt.verify(
                        response.accessToken.value,
                        as: JWT.Token.Access.self
                    )
                    request.auth.login(accessToken)

                    return response
                } catch {
                    if let jwtError = error as? JWTError {
                        print("JWT specific error:", jwtError)
                    }
                    throw Abort(.unauthorized)
                }
            },
            token: .init(
                access: { token in
                    @Dependency(Identity.Consumer.Client.self) var client
                    @Dependency(\.request) var request
                    guard let request else { throw Abort.requestUnavailable }

                    let currentToken = try await request.jwt.verify(token, as: JWT.Token.Access.self)

                    if !(Date() < currentToken.expiration.value) {
                        guard let refreshToken = request.cookies.refreshToken?.string else {
                            throw Abort(.unauthorized)
                        }
                        let newTokenResponse = try await client.authenticate.token.refresh(token: refreshToken)

                        let newAccessToken = try await request.jwt.verify(
                            newTokenResponse.accessToken.value,
                            as: JWT.Token.Access.self
                        )
                        request.auth.login(newAccessToken)

                        request.headers.bearerAuthorization = .init(token: newTokenResponse.accessToken.value)
                        request.cookies.accessToken = .accessToken(response: newTokenResponse, domain: provider.domain)
                        request.cookies.refreshToken = .refreshToken(response: newTokenResponse, domain: provider.domain)
                        return
                    }

                    request.auth.login(currentToken)
                },
                refresh: { token in
                    let route: Identity.Consumer.API = .authenticate(.token(.refresh(.init(token: token))))
                    let router = try Identity.Consumer.API.Router.prepare(baseRouter: router, baseURL: provider.baseURL, route: route)

                    @Dependency(URLRequest.Handler.self) var handleRequest

                    do {
                        let response = try await handleRequest(
                            for: makeRequest(router)(route),
                            decodingTo: Identity.Authentication.Response.self
                        )

                        @Dependency(\.request) var request
                        guard let request else { throw Abort.requestUnavailable }

                        request.cookies.accessToken = .accessToken(response: response, domain: provider.domain)

                        return response
                    } catch {
                        throw Abort(.unauthorized)
                    }
                }
            ),
            apiKey: { apiKey in
                let route: Identity.Consumer.API = .authenticate(.apiKey(.init(token: apiKey)))
                let router = try Identity.Consumer.API.Router.prepare(baseRouter: router, baseURL: provider.baseURL, route: route)

                @Dependency(URLRequest.Handler.self) var handleRequest

                do {
                    return try await handleRequest(
                        for: makeRequest(router)(route),
                        decodingTo: Identity.Authentication.Response.self
                    )
                } catch {
                    throw Abort(.unauthorized)
                }
            }
        )
    }
}
