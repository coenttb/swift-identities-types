//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 18/02/2025.
//

import Dependencies
import DependenciesMacros
import EmailAddress
import Foundation

extension Identity.Client {
    @DependencyClient
    public struct Email: @unchecked Sendable {
        public var change: Identity.Client.Email.Change
    }
}

extension Identity.Client.Email: TestDependencyKey {
    public static let testValue: Self = .init(
        change: .testValue
    )
}
extension Identity.Client.Email {
    @DependencyClient
    public struct Change: @unchecked Sendable {
        public var request: (_ newEmail: String) async throws -> Identity.Email.Change.Request.Result
        public var confirm: (_ token: String) async throws -> Identity.Email.Change.Confirm.Response
    }
}

// MARK: - Conveniences
extension Identity.Client.Email.Change {
    public func request(_ request: Identity.Email.Change.Request) async throws -> Identity.Email.Change.Request.Result {
        return try await self.request(newEmail: request.newEmail)
    }
}

extension Identity.Client.Email.Change {
    public func request(_ newEmail: EmailAddress) async throws -> Identity.Email.Change.Confirm.Response {
        return try await self.confirm(token: newEmail.rawValue)
    }
}

extension Identity.Client.Email.Change {
    public func confirm(_ confirm: Identity.Email.Change.Confirm) async throws -> Identity.Email.Change.Confirm.Response {
        return try await self.confirm(token: confirm.token)
    }
}
