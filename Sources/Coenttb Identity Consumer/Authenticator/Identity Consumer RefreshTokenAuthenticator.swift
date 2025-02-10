//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 06/02/2025.
//


import Identity_Consumer
import Coenttb_Identity_Shared
import Coenttb_Vapor
import JWT

extension Identity.Consumer {
    public struct RefreshTokenAuthenticator: AsyncMiddleware {
        public init() {}
        
        @Dependency(Identity.Consumer.Client.self) var client
        
        public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
            if let token = request.cookies["refresh_token"]?.string {
                try await withDependencies {
                    $0.request = request
                } operation: {
                    let response = try await client.authenticate.token.refresh(token: token)
                    request.cookies.accessToken = .accessToken(response: response, domain: nil)
                    request.cookies.refreshToken = .refreshToken(response: response, domain: nil)
                }
            }
            return try await next.respond(to: request)
        }
    }
}


