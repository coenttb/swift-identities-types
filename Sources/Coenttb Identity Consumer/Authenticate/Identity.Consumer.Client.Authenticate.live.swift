//
//  File.swift
//  coenttb-identities
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
    ) -> Self {
        @Dependency(\.identity.consumer.client) var client
        
        return .init(
            credentials: { username, password in
                do {
                    let response = try await client.handleRequest(
                        for: .authenticate(.credentials(.init(username: username, password: password))),
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
                }
                catch {
                    if let jwtError = error as? JWTError {
                        print("JWT specific error:", jwtError)
                    }
                    throw Abort(.unauthorized)
                }
            },
            token: .init(
                access: { token in
                    @Dependency(\.request) var request
                    guard let request else { throw Abort.requestUnavailable }

                    let currentToken = try await request.jwt.verify(token, as: JWT.Token.Access.self)
                    request.auth.login(currentToken)
                },
                refresh: { token in
                    do {
                        let response = try await client.handleRequest(
                            for: .authenticate(.token(.refresh(.init(token: token)))),
                            decodingTo: Identity.Authentication.Response.self
                        )

                        @Dependency(\.request) var request
                        guard let request else { throw Abort.requestUnavailable }
                        
                        let newAccessToken = try await request.jwt.verify(
                            response.accessToken.value,
                            as: JWT.Token.Access.self
                        )
                        
                        request.auth.login(newAccessToken)
                        
                        return response
                        
                    } catch {
                        throw Abort(.unauthorized)
                    }
                }
            ),
            apiKey: { apiKey in
                do {
                    return try await client.handleRequest(
                        for: .authenticate(.apiKey(.init(token: apiKey))),
                        decodingTo: Identity.Authentication.Response.self
                    )
                } catch {
                    throw Abort(.unauthorized)
                }
            }
        )
    }
}

