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
    public struct EmailChange: @unchecked Sendable {
        public var request: (_ newEmail: String) async throws -> Identity.EmailChange.Request.Result
        public var confirm: (_ token: String) async throws -> Identity.EmailChange.Confirm.Response
    }
}

extension Identity.Client.EmailChange {
    public func request(_ request: Identity.EmailChange.Request) async throws -> Identity.EmailChange.Request.Result {
        return try await self.request(newEmail: request.newEmail)
    }
}

extension Identity.Client.EmailChange {
    public func request(_ newEmail: EmailAddress) async throws -> Identity.EmailChange.Confirm.Response {
        return try await self.confirm(token: newEmail.rawValue)
    }
}

extension Identity.Client.EmailChange {
    public func confirm(_ confirm: Identity.EmailChange.Confirm) async throws -> Identity.EmailChange.Confirm.Response {
        return try await self.confirm(token: confirm.token)
    }
}
