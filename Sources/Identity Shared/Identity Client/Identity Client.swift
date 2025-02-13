//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2024.
//

import Foundation
import EmailAddress
import Dependencies
import DependenciesMacros

extension Identity {
    @DependencyClient
    public struct Client: @unchecked Sendable {
        public var authenticate: Identity.Client.Authenticate
        
        @DependencyEndpoint
        public var logout: () async throws -> Void
        
        @DependencyEndpoint
        public var reauthorize: (_ password: String) async throws -> JWT.Token
        
        public var create: Identity.Client.Create
        
        public var delete: Identity.Client.Delete
        
        public var emailChange: Identity.Client.EmailChange
        
        public var password: Identity.Client.Password        
        
        public init(
            authenticate: Identity.Client.Authenticate,
            logout: @escaping () async throws -> Void,
            create: Identity.Client.Create,
            delete: Identity.Client.Delete,
            emailChange: Identity.Client.EmailChange,
            password: Identity.Client.Password
        ) {
            self.create = create
            self.delete = delete
            self.authenticate = authenticate
            self.logout = logout
            self.password = password
            self.emailChange = emailChange
        }
    }
}


extension Identity.Client.Create {
    public func request(_ request: Identity.Create.Request) async throws {
        try await self.request(email: try .init(request.email), password: request.password)
    }
}

extension Identity.Client.Create {
    public func verify(_ verify: Identity.Create.Verify) async throws {
        try await self.verify(email: try .init(verify.email), token: verify.token)
    }
}

extension Identity.Client.Delete {
    public func request(_ request: Identity.Delete.Request) async throws {
        try await self.request(reauthToken: request.reauthToken)
    }
}

extension Identity.Client.EmailChange {
    public func request(_ request: Identity.EmailChange.Request) async throws -> Identity.Client.EmailChange.Request.Result {
        return try await self.request(newEmail: try .init(request.newEmail))
    }
}

extension Identity.Client.EmailChange {
    public func confirm(_ confirm: Identity.EmailChange.Confirm) async throws {
        try await self.confirm(token: confirm.token)
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
