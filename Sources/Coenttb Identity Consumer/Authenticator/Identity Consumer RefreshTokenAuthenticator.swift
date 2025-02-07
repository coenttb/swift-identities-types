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

extension Identity.Consumer {
    public struct RefreshTokenAuthenticator: AsyncBearerAuthenticator {
                
        public init() {}
        
        public func authenticate(
            bearer: BearerAuthorization,
            for request: Request
        ) async throws {
            @Dependency(Identity.Consumer.Client.self) var client
            let _ = try await client.authenticate.token.refresh(token: bearer.token)
        }
    }
}
