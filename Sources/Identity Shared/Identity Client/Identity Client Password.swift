//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 12/02/2025.
//

import Foundation
import EmailAddress
import Dependencies
import DependenciesMacros

extension Identity.Client {
    @DependencyClient
    public struct Password: @unchecked Sendable {
        public var reset: Password.Reset
        public var change: Password.Change
        
        public init(reset: Password.Reset, change: Password.Change) {
            self.reset = reset
            self.change = change
        }
    }
}

extension Identity.Client.Password {
    @DependencyClient
    public struct Reset: @unchecked Sendable {
        public var request: (_ email: EmailAddress) async throws -> Void
        public var confirm: (_ newPassword: String, _ token: String) async throws -> Void
    }
}


extension Identity.Client.Password {
    @DependencyClient
    public struct Change: @unchecked Sendable {
        public var request: (_ currentPassword: String, _ newPassword: String) async throws -> Void
    }
}

extension Identity.Client.Password.Reset {
    public func request(_ request: Identity.Password.Reset.Request) async throws {
        try await self.request(email: try .init(request.email))
    }
}

extension Identity.Client.Password.Reset {
    public func confirm(_ confirm: Identity.Password.Reset.Confirm) async throws {
        try await self.confirm(newPassword: confirm.newPassword, token: confirm.token)
    }
}

extension Identity.Client.Password.Change {
    public func request(_ request: Identity.Password.Change.Request) async throws {
        try await self.request(
            currentPassword: request.currentPassword,
            newPassword: request.newPassword
        )
    }
}
