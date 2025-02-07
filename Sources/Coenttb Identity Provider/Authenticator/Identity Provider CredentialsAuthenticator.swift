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
import Fluent

extension Identity.Provider {
    public struct CredentialsAuthenticator: AsyncBasicAuthenticator {
              
        @Dependency(Identity.Provider.Client.self) var client
        
        public init(){}
        
        public func authenticate(
            basic: BasicAuthorization,
            for request: Request
        ) async throws {
            let _ = try await client.authenticate.credentials(credentials: .init(email: basic.username, password: basic.password))
        }
    }
}
