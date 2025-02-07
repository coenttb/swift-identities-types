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
    public struct AccessTokenAuthenticator: AsyncBearerAuthenticator {
                
        public init() {}
        
        public func authenticate(
            bearer: BearerAuthorization,
            for request: Request
        ) async throws {
            @Dependency(Identity.Consumer.Client.self) var client
            try await client.authenticate.token.access(token: bearer.token)
        }
    }
}
