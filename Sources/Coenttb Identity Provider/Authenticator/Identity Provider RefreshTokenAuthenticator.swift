//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 06/02/2025.
//


import Dependencies
@preconcurrency import Vapor
import JWT
import Coenttb_Identity_Shared

extension Identity.Provider {
    public struct RefreshTokenAuthenticator: AsyncMiddleware {
        public init() {}
        
        public func respond(
            to request: Request,
            chainingTo next: AsyncResponder
        ) async throws -> Response {
            @Dependency(Identity.Provider.Client.self) var client
            
            if let refreshToken = request.cookies.refreshToken?.string {
                do {
                    let _ = try await client.authenticate.token.refresh(token: refreshToken)
                    print("successful refresh token")
                } catch {
                }
            }
            
            return try await next.respond(to: request)
        }
    }
}
