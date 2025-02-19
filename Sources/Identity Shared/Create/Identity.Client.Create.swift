//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 12/02/2025.
//

import Dependencies
import DependenciesMacros
import EmailAddress
import Foundation

extension Identity.Client {
    @DependencyClient
    public struct Create: @unchecked Sendable {
        @DependencyEndpoint
        public var request: (_ email: String, _ password: String) async throws -> Void

        @DependencyEndpoint
        public var verify: (_ email: String, _ token: String) async throws -> Void
    }
}

extension Identity.Client.Create {
    public func request(_ request: Identity.Create.Request) async throws {
        try await self.request(email: request.email, password: request.password)
    }
}

extension Identity.Client.Create {
    public func verify(_ verify: Identity.Create.Verify) async throws {
        try await self.verify(email: verify.email, token: verify.token)
    }
}
