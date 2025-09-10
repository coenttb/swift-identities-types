//
//  Identity.Client.OAuth.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2025.
//

import Dependencies
import DependenciesMacros
import Foundation

extension Identity.Client {
    /// OAuth authentication client for managing OAuth provider integrations
    @DependencyClient
    public struct OAuth: @unchecked Sendable {
        /// Register an OAuth provider
        @DependencyEndpoint
        public var registerProvider: (any Identity.OAuth.Provider) async throws -> Void
        
        /// Get a registered OAuth provider by identifier
        @DependencyEndpoint
        public var provider: (_ identifier: String) async throws -> (any Identity.OAuth.Provider)?
        
        /// Get all registered OAuth providers
        @DependencyEndpoint
        public var providers: () async throws -> [any Identity.OAuth.Provider]
        
        /// Generate authorization URL for OAuth flow
        @DependencyEndpoint
        public var authorizationURL: (
            _ provider: String,
            _ redirectURI: String
        ) async throws -> URL
        
        /// Handle OAuth callback and exchange code for tokens
        @DependencyEndpoint
        public var callback: (
            _ credentials: Identity.OAuth.Credentials
        ) async throws -> Identity.Authentication.Response
        
        /// Get OAuth connection for current identity
        @DependencyEndpoint
        public var connection: (
            _ provider: String
        ) async throws -> OAuthConnection?
        
        /// Disconnect OAuth provider
        @DependencyEndpoint
        public var disconnect: (
            _ provider: String
        ) async throws -> Void
        
        /// OAuth connection information
        public struct OAuthConnection: Codable, Sendable {
            public let provider: String
            public let providerUserId: String
            public let connectedAt: Date
            public let scopes: [String]?
            
            public init(
                provider: String,
                providerUserId: String,
                connectedAt: Date,
                scopes: [String]? = nil
            ) {
                self.provider = provider
                self.providerUserId = providerUserId
                self.connectedAt = connectedAt
                self.scopes = scopes
            }
        }
    }
}