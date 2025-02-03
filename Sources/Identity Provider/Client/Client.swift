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

extension Identity.Provider {
    @DependencyClient
    public struct Client: @unchecked Sendable {
        public var create: Client.Create
        
        public var delete: Client.Delete
        
        @DependencyEndpoint
        public var login: (_ email: EmailAddress, _ password: String) async throws -> Void
        
        @DependencyEndpoint
        public var currentUser: () async throws -> User?
        
        @DependencyEndpoint
        public var update: (User?) async throws -> User?
        
        @DependencyEndpoint
        public var logout: () async throws -> Void
        
        public var password: Client.Password
        
        public var emailChange: Client.EmailChange
        
//        public var multifactorAuthentication: Client.MultifactorAuthentication?
        
        public init(
            create: Client.Create,
            delete: Client.Delete,
            login: @escaping (_: EmailAddress, _: String) -> Void,
            currentUser: @escaping () -> User?,
            update: @escaping (User?) -> User?,
            logout: @escaping () -> Void,
            password: Client.Password,
            emailChange: Client.EmailChange
//            multifactorAuthentication: Client.MultifactorAuthentication? = nil
        ) {
            self.create = create
            self.delete = delete
            self.login = login
            self.currentUser = currentUser
            self.update = update
            self.logout = logout
            self.password = password
            self.emailChange = emailChange
//            self.multifactorAuthentication = multifactorAuthentication
        }
    }
}



extension Identity.Provider.Client {
    @DependencyClient
    public struct Create: @unchecked Sendable {
        @DependencyEndpoint
        public var request: (_ email: EmailAddress, _ password: String) async throws -> Void
        
        @DependencyEndpoint
        public var verify: (_ token: String, _ email: EmailAddress) async throws -> Void
    }
}

extension Identity.Provider.Client {
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

extension Identity.Provider.Client.Password {
    @DependencyClient
    public struct Reset: @unchecked Sendable {
        public var request: (_ email: EmailAddress) async throws -> Void
        public var confirm: (_ newPassword: String, _ token: String) async throws -> Void
    }
}

extension Identity.Provider.Client.Password {
    @DependencyClient
    public struct Change: @unchecked Sendable {
        public var request: (_ currentPassword: String, _ newPassword: String) async throws -> Void
    }
}

extension Identity.Provider.Client {
    @DependencyClient
    public struct EmailChange: @unchecked Sendable {
        public var request: (_ newEmail: EmailAddress?) async throws -> Void
        public var confirm: (_ token: String) async throws -> EmailAddress
    }
}

extension Identity.Provider.Client {
    @DependencyClient
    public struct Delete: @unchecked Sendable {
        public var request: (
//            _ userId: UUID,
            _ reauthToken: String
        ) async throws -> Void
        
        public var cancel: (/*_ userId: User.ID*/) async throws -> Void
        
        public var confirm: (/*_ userId: User.ID*/) async throws -> Void
        
        public var anonymize: (/*_ userId: User.ID*/) async throws -> Void
    }
}

