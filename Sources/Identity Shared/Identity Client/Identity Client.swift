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
        public var reauthorize: (_ password: String) async throws -> JWT.Response
        
        public var create: Identity.Client.Create
        
        public var delete: Identity.Client.Delete
        
        public var emailChange: Identity.Client.EmailChange
        
        public var password: Identity.Client.Password        
        
        public var multifactorAuthentication: Identity.Client.Authenticate.Multifactor?
        
        public init(
            authenticate: Identity.Client.Authenticate,
            logout: @escaping () -> Void,
            create: Identity.Client.Create,
            delete: Identity.Client.Delete,
            emailChange: Identity.Client.EmailChange,
            password: Identity.Client.Password,
            multifactorAuthentication: Identity.Client.Authenticate.Multifactor? = nil
        ) {
            self.create = create
            self.delete = delete
            self.authenticate = authenticate
            self.logout = logout
            self.password = password
            self.emailChange = emailChange
            self.multifactorAuthentication = multifactorAuthentication
        }
    }
}

extension Identity.Client {
    @DependencyClient
    public struct Create: @unchecked Sendable {
        @DependencyEndpoint
        public var request: (_ email: EmailAddress, _ password: String) async throws -> Void
        
        @DependencyEndpoint
        public var verify: (_ email: EmailAddress, _ token: String) async throws -> Void
    }
}

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

extension Identity.Client {
    @DependencyClient
    public struct EmailChange: @unchecked Sendable {
        public var request: (_ newEmail: EmailAddress?) async throws -> Void
        public var confirm: (_ token: String) async throws -> Void
    }
}

extension Identity.Client {
    @DependencyClient
    public struct Delete: @unchecked Sendable {
        public var request: (
//            _ userId: UUID,
            _ reauthToken: String
        ) async throws -> Void
        
        public var cancel: (/*_ userId: User.ID*/) async throws -> Void
        
        public var confirm: (/*_ userId: User.ID*/) async throws -> Void
    }
}

extension Identity.Client {
    @DependencyClient
    public struct Authenticate: @unchecked Sendable {
        
        @DependencyEndpoint
        public var credentials: (
            _ credentials: Identity.Authentication.Credentials
        ) async throws -> JWT.Response
        
        public var token: Identity.Client.Authenticate.Token
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
        ) async throws -> JWT.Response
    }
}
