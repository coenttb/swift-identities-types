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
import EmailAddress
import Dependencies
import Identity_Consumer

extension Identity.Consumer {
    public struct CredentialsAuthenticator: AsyncBasicAuthenticator {
        public typealias User = Identity.Consumer.User
        
        public func authenticate(
            basic: BasicAuthorization,
            for request: Request
        ) async throws {
            
            @Dependency(Identity.Consumer.Client.self) var client
            
            let response = try await client.authenticate.credentials(
                .init(
                    email: try .init(basic.username),
                    password: basic.password
                )
            )
            
            request.headers.bearerAuthorization = .init(token: response.token)
            
            let user = try await request.jwt.verify(as: Identity.Consumer.User.self)
            
            request.auth.login(user)

        }
    }
}
