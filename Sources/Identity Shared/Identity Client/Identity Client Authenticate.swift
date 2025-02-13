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
    public struct Authenticate: @unchecked Sendable {
        
        @DependencyEndpoint
        public var credentials: (
            _ username: String,
            _ password: String
        ) async throws -> Identity.Authentication.Response
        
        public var token: Identity.Client.Authenticate.Token
        
        @DependencyEndpoint
        public var apiKey: (
            _ apiKey: String
        ) async throws -> Identity.Authentication.Response
        
        public var multifactor: Identity.Client.Authenticate.Multifactor?
    }
}

extension Identity.Client.Authenticate {
    @DependencyClient
    public struct Token: @unchecked Sendable {
        public var access: (
            _ token: String
        ) async throws -> Void
        
        public var refresh: (
            _ token: String
        ) async throws -> Identity.Authentication.Response
    }
}

import BearerAuth
extension Identity.Client.Authenticate {
    public func credentials(_ credentials: Identity.Authentication.Credentials) async throws -> Identity.Authentication.Response {
        try await self.credentials(username: credentials.email, password: credentials.password)
    }
}

extension Identity.Client.Authenticate.Token {
    public func access(_ access: BearerAuth) async throws {
        try await self.access(access.token)
    }
}

extension Identity.Client.Authenticate.Token {
    public func refresh(_ refresh: BearerAuth) async throws -> Identity.Authentication.Response {
        return try await self.refresh(refresh.token)
    }
}


extension Identity.Client.Authenticate {
    public func apiKey(_ apiKey: BearerAuth) async throws -> Identity.Authentication.Response {
        return try await self.apiKey(apiKey.token)
    }
}
