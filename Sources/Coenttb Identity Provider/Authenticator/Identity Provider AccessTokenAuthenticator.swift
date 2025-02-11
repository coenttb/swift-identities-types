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
    public struct AccessTokenAuthenticator: AsyncBearerAuthenticator {                
        public init() {}
        
        @Dependency(Identity.Provider.Client.self) var client
        
        public func authenticate(
            bearer: BearerAuthorization,
            for request: Request
        ) async throws {
            do {
                try await client.authenticate.token.access(token: bearer.token)
            } catch {
                
            }
        }
    }
}
