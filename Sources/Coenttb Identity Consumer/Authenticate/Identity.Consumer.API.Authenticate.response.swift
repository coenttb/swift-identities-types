//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 16/10/2024.
//

import Coenttb_Vapor
import Coenttb_Web
import Favicon
import Identities

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
                    
                    let identityAuthenticationResponse = try await client.login(
                        accessToken: access.token,
                        refreshToken: \.cookies.refreshToken?.string
                    )
                        
                    return Response.success(true)
                        .withTokens(for: identityAuthenticationResponse)
                    
                case .refresh(let refresh):
                    let identityAuthenticationResponse = try await client.authenticate.token.refresh(token: refresh.token)
                    
                    return Response.success(true)
                        .withTokens(for: identityAuthenticationResponse)
                }

            case .credentials(let credentials):
                do {
                    let identityAuthenticationResponse = try await client.authenticate.credentials(credentials)
                    
                    // Debug log to verify tokens are created
                    logger.debug("Identity.Consumer.API.Authenticate.response will return credentials with cookies")
                    
                    // Return response with tokens attached as cookies
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
            let response = Response.success(false, message: "Failed to authenticate with error: \(error)")
            response.expire(cookies: .identity)
            return response
        }
    }
}
