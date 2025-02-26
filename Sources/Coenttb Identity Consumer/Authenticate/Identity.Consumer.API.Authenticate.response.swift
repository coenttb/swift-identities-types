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
                    do {
                        return try await Response.success(true)
                            .withTokens(
                                for: client.login(
                                    accessToken: access.token,
                                    refreshToken: \.cookies.refreshToken?.string
                                )
                            )
                    } catch {
                        print("Failed in access token case with error:", error)
                        throw Abort(.internalServerError, reason: "Failed to authenticate account: \(error)")
                    }
                    
                case .refresh(let refresh):
                    do {
                        return try await Response.success(true)
                            .withTokens(for: client.authenticate.token.refresh(token: refresh.token))
                    } catch {
                        print("Failed in refresh token case with error:", error)
                        throw Abort(.internalServerError, reason: "Failed to authenticate account: \(error)")
                    }
                }

            case .credentials(let credentials):
                do {
                    return try await Response.success(true)
                        .withTokens(for: client.authenticate.credentials(credentials))
                } catch {
                    print("Failed in credentials case with error:", error)
                    throw Abort(.internalServerError, reason: "Failed to authenticate account: \(error)")
                }
                
            case .apiKey(let apiKey):
                do {
                    return try await Response.success(true)
                        .withTokens(for: client.authenticate.apiKey(apiKey: apiKey.token))
                } catch {
                    print("Failed in API case with error:", error)
                    throw Abort(.internalServerError, reason: "Failed to authenticate account: \(error)")
                }
            }
        } catch {
            let response = Response.success(false, message: "Failed to authenticate with error: \(error)")
            response.expire(cookies: .identity)
            return response
        }
    }
}
