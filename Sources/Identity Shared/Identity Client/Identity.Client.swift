//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2024.
//

import Dependencies
import DependenciesMacros
import EmailAddress
import Foundation

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

        public var email: Identity.Client.Email

        public var password: Identity.Client.Password

        public init(
            authenticate: Identity.Client.Authenticate,
            logout: @escaping () async throws -> Void,
            create: Identity.Client.Create,
            delete: Identity.Client.Delete,
            email: Identity.Client.Email,
            password: Identity.Client.Password
        ) {
            self.create = create
            self.delete = delete
            self.authenticate = authenticate
            self.logout = logout
            self.password = password
            self.email = email
        }
    }
}

// MARK: Conveniences
extension Identity.Client {
    public func login(username: String, password: String) async throws -> Identity.Authentication.Response {
        try await self.authenticate.credentials(username: username, password: password)
    }
}

extension Identity.Client {
    public func login(accessToken: String) async throws {
        try await self.authenticate.token.access(.init(token: accessToken))
    }
}

extension Identity.Client {
    public func login(apiKey: String) async throws -> Identity.Authentication.Response {
        try await self.authenticate.apiKey(.init(token: apiKey))
    }
}
