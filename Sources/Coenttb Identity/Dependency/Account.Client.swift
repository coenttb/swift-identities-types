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

@DependencyClient
public struct Client<User>: @unchecked Sendable {
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
}

extension Client {
    @DependencyClient
    public struct Create: @unchecked Sendable {
        @DependencyEndpoint
        public var request: (_ email: EmailAddress, _ password: String) async throws -> Void
        
        @DependencyEndpoint
        public var verify: (_ token: String, _ email: EmailAddress) async throws -> Void
    }
}

extension Client {
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

extension Client.Password {
    @DependencyClient
    public struct Reset: @unchecked Sendable {
        public var request: (_ email: EmailAddress) async throws -> Void
        public var confirm: (_ token: String, _ newPassword: String) async throws -> Void
    }
}

extension Client.Password {
    @DependencyClient
    public struct Change: @unchecked Sendable {
        public var request: (_ currentPassword: String, _ newPassword: String) async throws -> Void
    }
}

extension Client {
    public enum RequestEmailChangeError: Sendable, Error {
        case unauthorized
        case emailIsNil
    }
}

extension Client {
    @DependencyClient
    public struct EmailChange: @unchecked Sendable {
        public var request: (_ newEmail: EmailAddress?) async throws -> Void
        public var confirm: (_ token: String) async throws -> Void
    }
}

extension Client {
    @DependencyClient
    public struct Delete: @unchecked Sendable {
        public var request: (
            _ userId: UUID,
            _ deletionRequestedAt: Date
        ) async throws -> Void
        
        public var cancel: (_ userId: UUID) async throws -> Void
        
        public var confirm: (_ userId: UUID) async throws -> Void
        
        public var anonymize: (_ userId: UUID) async throws -> Void
    }
}

extension Client: TestDependencyKey {
    public static var testValue: Client {
        .init(
            create: .testValue,
            delete: .testValue,
            password: .testValue,
            emailChange: .testValue
        )
    }
}

extension Client.Create: TestDependencyKey {
    public static var testValue: Self {
        .init(
            request: { _, _ in },
            verify: { _, _ in }
        )
    }
}

extension Client.Password: TestDependencyKey {
    public static var testValue: Self {
        .init(
            reset: .init(),
            change: .init()
        )
    }
}

extension Client.EmailChange: TestDependencyKey {
    public static var testValue: Self {
        .init()
    }
}

extension Coenttb_Identity.Client.Delete: TestDependencyKey {
    public static var testValue: Self { .init() }
}



