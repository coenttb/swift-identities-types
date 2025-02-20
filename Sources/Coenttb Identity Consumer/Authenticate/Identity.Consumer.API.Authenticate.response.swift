//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 16/10/2024.
//

import Coenttb_Vapor
import Coenttb_Web
import Favicon
import Identity_Consumer

extension Identity.Consumer.API.Authenticate {
    package static func response(
        authenticate: Identity.Consumer.API.Authenticate
    ) async throws -> Response {

        @Dependency(\.identity.consumer.client) var client

        do {
            switch authenticate {
            case .token(let token):
                switch token {
                case .access(let access):
                    
                    if let identityAuthenticationResponse = try await client.login(
                        accessToken: access.token,
                        refreshToken: \.cookies.refreshToken?.string
                    ) {
                        return Response.success(true)
                            .withTokens(for: identityAuthenticationResponse)
                    }
                    return Response.success(true)
                    
                case .refresh(let refresh):
                    let identityAuthenticationResponse = try await client.authenticate.token.refresh(token: refresh.token)
                    
                    return Response.success(true)
                        .withTokens(for: identityAuthenticationResponse)
                }

            case .credentials(let credentials):
                do {
                    let identityAuthenticationResponse = try await client.authenticate.credentials(credentials)
                    @Dependency(\.identity.consumer.cookies.accessToken) var accessTokenConfiguration
                    @Dependency(\.identity.consumer.cookies.refreshToken) var refreshTokenConfiguration
                    @Dependency(\.logger) var logger
                    
                    logger.debug("Identity.Consumer.API.Authenticate.response will return credentials with cookies")
                    
                    return Response.success(true)
                        .withTokens(for: identityAuthenticationResponse)
                } catch {
                    print("Failed in credentials case with error:", error)
                    throw Abort(.internalServerError, reason: "Failed to authenticate account: \(error)")
                }

            case .apiKey(let apiKey):
                let data = try await client.authenticate.apiKey(apiKey: apiKey.token)
                return Response.success(true, data: data)

            }

        } catch {
            throw Abort(.internalServerError, reason: "Failed to authenticate account")
        }
    }
}
