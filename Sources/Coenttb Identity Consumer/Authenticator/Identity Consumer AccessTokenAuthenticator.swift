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
    public struct AccessTokenAuthenticator: AsyncSessionAuthenticator {
        public typealias User = JWT.Token.Access
        
        public init(){}
        
        public func authenticate(sessionID: String, for request: Request) async throws {
            
            try await withDependencies {
                $0.request = request
            } operation: {
                @Dependency(Identity.Consumer.Client.self) var client
                try await client.authenticate.token.access(token: sessionID)
            }
        }
    }
}


