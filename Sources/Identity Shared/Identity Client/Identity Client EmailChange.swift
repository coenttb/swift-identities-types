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
        public var request: (_ newEmail: EmailAddress?) async throws -> Identity.Client.EmailChange.Request.Result
        public var confirm: (_ token: String) async throws -> Identity.Authentication.Response
    }
}

extension Identity.Client.EmailChange {
    public enum Request { }
}

extension Identity.Client.EmailChange.Request {
    public enum Result: Codable, Hashable, Sendable {
        case success
//        case allowed
        case requiresReauthentication
    }
}

extension Identity.Client.EmailChange {
    public func request(_ request: Identity.EmailChange.Request) async throws -> Identity.Client.EmailChange.Request.Result {
        return try await self.request(newEmail: try .init(request.newEmail))
    }
}

extension Identity.Client.EmailChange {
    public func confirm(_ confirm: Identity.EmailChange.Confirm) async throws -> Identity.Authentication.Response {
        return try await self.confirm(token: confirm.token)
    }
}
