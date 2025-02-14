//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 06/02/2025.
//

import Coenttb_Identity_Shared
import Dependencies
import JWT
@preconcurrency import Vapor

extension Identity.Provider {
    public struct AccessTokenAuthenticator: AsyncBearerAuthenticator {
        public init() {}

        @Dependency(Identity.Provider.Client.self) var client

        public func authenticate(
            bearer: BearerAuthorization,
            for request: Request
        ) async throws {
            do {
                try await withDependencies {
                    $0.request = request
                } operation: {
                    try await client.authenticate.token.access(token: bearer.token)
                    print("successful access token authentication")
                }

            } catch {

            }
        }
    }
}
