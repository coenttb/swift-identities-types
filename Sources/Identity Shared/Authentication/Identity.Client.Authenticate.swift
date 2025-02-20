//
//  Identity.Client.Authenticate.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 12/02/2025.
//

import Dependencies
import DependenciesMacros
import EmailAddress
import Foundation

extension Identity.Client {
    /// A client interface for handling user authentication operations.
    ///
    /// The `Authenticate` struct provides methods for authenticating users through various mechanisms:
    /// - Username/password credentials
    /// - Access/refresh tokens
    /// - API keys
    ///
    /// Example usage:
    /// ```swift
    /// let auth = Identity.Client.Authenticate(...)
    ///
    /// // Authenticate with credentials
    /// let response = try await auth.credentials(
    ///     username: "user@example.com",
    ///     password: "password123"
    /// )
    /// ```
    @DependencyClient
    public struct Authenticate: @unchecked Sendable {
        /// Authenticates a user with username and password credentials.
        ///
        /// - Parameters:
        ///   - username: The user's email address or username
        ///   - password: The user's password
        /// - Returns: An authentication response containing access and refresh tokens
        /// - Throws: Authentication errors if credentials are invalid
        @DependencyEndpoint
        public var credentials: (
            _ username: String,
            _ password: String
        ) async throws -> Identity.Authentication.Response

        /// Token-based authentication operations.
        public var token: Identity.Client.Authenticate.Token

        /// Authenticates a user with an API key.
        ///
        /// - Parameter apiKey: The API key to authenticate with
        /// - Returns: An authentication response containing access and refresh tokens
        /// - Throws: Authentication errors if the API key is invalid
        @DependencyEndpoint
        public var apiKey: (
            _ apiKey: String
        ) async throws -> Identity.Authentication.Response
    }
}

extension Identity.Client.Authenticate {
    /// Handles token-based authentication operations.
    ///
    /// Provides functionality for:
    /// - Validating access tokens
    /// - Refreshing expired tokens
    @DependencyClient
    public struct Token: @unchecked Sendable {
        /// Validates an access token.
        ///
        /// - Parameter token: The access token to validate
        /// - Throws: Authentication errors if the token is invalid
        public var access: (
            _ token: String
        ) async throws -> Void

        /// Refreshes an expired token.
        ///
        /// - Parameter token: The refresh token to use
        /// - Returns: A new authentication response with fresh tokens
        /// - Throws: Authentication errors if the refresh token is invalid
        public var refresh: (
            _ token: String
        ) async throws -> Identity.Authentication.Response
    }
}

import BearerAuth

extension Identity.Client.Authenticate {
    /// Authenticates using a credentials object.
    ///
    /// Convenience method that unpacks the credentials and calls the underlying authentication method.
    ///
    /// - Parameter credentials: The authentication credentials
    /// - Returns: An authentication response containing access and refresh tokens
    /// - Throws: Authentication errors if credentials are invalid
    public func credentials(_ credentials: Identity.Authentication.Credentials) async throws -> Identity.Authentication.Response {
        try await self.credentials(username: credentials.username, password: credentials.password)
    }
}

extension Identity.Client.Authenticate.Token {
    /// Validates a bearer authentication token.
    ///
    /// - Parameter access: The bearer authentication token to validate
    /// - Throws: Authentication errors if the token is invalid
    public func access(_ access: BearerAuth) async throws {
        try await self.access(access.token)
    }
}

extension Identity.Client.Authenticate.Token {
    /// Refreshes an expired bearer authentication token.
    ///
    /// - Parameter refresh: The bearer refresh token
    /// - Returns: A new authentication response with fresh tokens
    /// - Throws: Authentication errors if the refresh token is invalid
    public func refresh(_ refresh: BearerAuth) async throws -> Identity.Authentication.Response {
        return try await self.refresh(refresh.token)
    }
}

extension Identity.Client.Authenticate {
    /// Authenticates using a bearer API key.
    ///
    /// - Parameter apiKey: The bearer API key to authenticate with
    /// - Returns: An authentication response containing access and refresh tokens
    /// - Throws: Authentication errors if the API key is invalid
    public func apiKey(_ apiKey: BearerAuth) async throws -> Identity.Authentication.Response {
        return try await self.apiKey(apiKey.token)
    }
}
