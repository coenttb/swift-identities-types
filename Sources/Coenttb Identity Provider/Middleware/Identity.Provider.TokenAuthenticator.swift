//
//  TokenAuthenticator.swift
//  coenttb-identities
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
        
        @Dependency(\.identity.provider.client) var client
        
        public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
            return try await withDependencies {
                $0.request = request
            } operation: {
                if let bearerAuth = request.headers.bearerAuthorization {
                    // First try access token verification
                    do {
                        try await client.authenticate.token.access(token: bearerAuth.token)
                        return try await next.respond(to: request)
                    } catch {
                        // If access token fails, try refresh token verification
                        // This handles the case when a refresh token is sent as a Bearer token
                        do {
                            _ = try await client.authenticate.token.refresh(token: bearerAuth.token) 
                            return try await next.respond(to: request)
                        } catch {
                            // Both verifications failed
                        }
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
                return try await next.respond(to: request)
            }
        }
    }
}
