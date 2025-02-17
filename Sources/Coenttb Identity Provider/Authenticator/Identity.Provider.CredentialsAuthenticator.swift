//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 06/02/2025.
//

import Coenttb_Identity_Shared
import Dependencies
import EmailAddress
import Fluent
import JWT
@preconcurrency import Vapor

extension Identity.Provider {
    public struct CredentialsAuthenticator: AsyncBasicAuthenticator {

        @Dependency(\.identity.provider.client) var client

        public init() {}

        public func authenticate(
            basic: BasicAuthorization,
            for request: Request
        ) async throws {
            try await withDependencies {
                $0.request = request
            } operation: {
                _ = try await client.authenticate.credentials(username: basic.username, password: basic.password)
            }

        }
    }
}
