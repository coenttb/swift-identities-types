//
//  TokenAuthenticator.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 17/02/2025.
//

import Coenttb_Identity_Shared
import Coenttb_Vapor
import Dependencies
import JWT
@preconcurrency import Vapor

extension Identity.Provider {
    public struct TokenAuthenticator: AsyncMiddleware {
        public init() {}
        
        @Dependency(Identity.Provider.Client.self) var client
        
        public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
            return await withDependencies {
                $0.request = request
            } operation: {
                if let bearerAuth = request.headers.bearerAuthorization {
                    do {
                        try await client.authenticate.token.access(token: bearerAuth.token)
                        return try await next.respond(to: request)
                    } catch {
                    }
                }
                
                if let accessToken = request.cookies.accessToken?.string {
                    do {
                        _ = try await client.authenticate.token.access(token: accessToken)
                        return try await next.respond(to: request)
                    } catch {

                    }
                }
                
                if let refreshToken = request.cookies.refreshToken?.string {
                    do {
                        _ = try await client.authenticate.token.refresh(token: refreshToken)
                        return try await next.respond(to: request)
                    } catch {

                    }
                }
                
                let response = Response(status: .unauthorized)
                response.expire(cookies: .identity)
                return response
            }
        }
    }
}
