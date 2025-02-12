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
            _ credentials: Identity.Authentication.Credentials
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
