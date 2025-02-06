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
    public struct TokenAuthenticator: AsyncBearerAuthenticator {
        public typealias User = Identity_Shared.JWT.Payload
                
        public init() {}
        
        public func authenticate(
            bearer: BearerAuthorization,
            for request: Request
        ) async throws {
            let user = try await request.jwt.verify(
                bearer.token,
                as: Identity_Shared.JWT.Payload.self
            )

            @Dependency(Identity.Consumer.Client.self) var client
            
            let _ = try await client.authenticate.bearer(token: bearer.token)
            
            request.auth.login(user)
        }
    }
}
