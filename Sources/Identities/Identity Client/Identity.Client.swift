//
//  Identity.Client.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2024.
//

import Dependencies
import DependenciesMacros
import EmailAddress
import Foundation
import Swift_Web

extension Identity {
    /// A client interface for interacting with identity and authentication services.
    ///
    /// The `Client` type provides a high-level API for performing identity-related operations in a
    /// type-safe manner. It handles all authentication, creation, and
    /// email- and password updates.
    ///
    /// You can use the client to perform common operations like logging in:
    /// ```swift
    /// let client = Identity.Client(...)
    ///
    /// // Login with username/password
    /// let response = try await client.login(
    ///   username: "user@example.com",
    ///   password: "password123"
    /// )
    ///
    /// // Or login with an access token
    /// try await client.login(accessToken: "jwt-token-string")
    /// ```
    ///
    /// The client provides interfaces for:
    /// - Identity authentication (credentials, tokens, API keys)
    /// - Identity creation and deletion
    /// - Password management
    /// - Email verification and updates
    /// - Session management
    ///
    /// Each operation is provided through a dedicated interface:
    /// - ``authenticate`` for authentication operations
    /// - ``create`` for identity creation
    /// - ``email`` for email management
    /// - ``password`` for password operations
    /// - ``delete`` for identity deletion
    @DependencyClient
    public struct Client: @unchecked Sendable {
        /// Interface for all authentication-related operations
        public var authenticate: Identity.Client.Authenticate = .init()

        /// Logs out the current user and invalidates their session
        @DependencyEndpoint
        public var logout: () async throws -> Void

        /// Re-authenticates the current user for sensitive operations
        ///
        /// - Parameter password: The user's current password
        /// - Returns: A JWT token for the re-authenticated session
        @DependencyEndpoint
        public var reauthorize: (_ password: String) async throws -> JWT.Token

        /// Interface for identity creation operations
        public var create: Identity.Client.Create = .init()

        /// Interface for identity deletion operations
        public var delete: Identity.Client.Delete = .init()

        /// Interface for email management operations
        public var email: Identity.Client.Email = .init(change: .init())

        /// Interface for password management operations
        public var password: Identity.Client.Password = .init(reset: .init(), change: .init())

        /// Creates a new identity client with the specified interfaces.
        ///
        /// - Parameters:
        ///   - authenticate: The authentication interface
        ///   - logout: A closure that handles user logout
        ///   - create: The identity creation interface
        ///   - delete: The identity deletion interface
        ///   - email: The email management interface
        ///   - password: The password management interface
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

// MARK: - Conveniences
extension Identity.Client {
    /// Convenience method to authenticate an identity with username and password credentials.
    ///
    /// - Parameters:
    ///   - username: The user's email address or username
    ///   - password: The user's password
    /// - Returns: An authentication response containing access and refresh tokens
    public func login(username: String, password: String) async throws -> Identity.Authentication.Response {
        try await self.authenticate.credentials(username: username, password: password)
    }

    /// Convenience method to authenticate an identity with an access token.
    ///
    /// - Parameter accessToken: A valid JWT access token
    public func login(accessToken: String) async throws {
        try await self.authenticate.token.access(.init(token: accessToken))
    }

    /// Convenience method to authenticate an identity with an API key.
    ///
    /// - Parameter apiKey: A valid API key
    /// - Returns: An authentication response containing access and refresh tokens
    public func login(apiKey: String) async throws -> Identity.Authentication.Response {
        try await self.authenticate.apiKey(.init(token: apiKey))
    }
}
