//
//  Identity.OAuth.Client.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2025.
//

import Dependencies
import Foundation

extension Identity.OAuth {
    /// OAuth authentication client for managing OAuth provider integrations
    @Witness
    public struct Client: @unchecked Sendable {
        /// Register an OAuth provider
        public var registerProvider:
            (any Identity.OAuth.Provider) async throws(Identity.OAuth.Client.Error) -> Void

        /// Get a registered OAuth provider by identifier
        public var provider:
            (_ identifier: String) async throws(any Swift.Error) -> (any Identity.OAuth.Provider)?

        /// Get all registered OAuth providers
        public var providers: () async throws(any Swift.Error) -> [any Identity.OAuth.Provider]

        /// Generate authorization URL for OAuth flow
        public var authorizationURL:
            (
                _ provider: String,
                _ redirectURI: String
            ) async throws(any Swift.Error) -> URL

        /// Handle OAuth callback and exchange code for tokens
        public var callback:
            (
                _ callbackRequest: Identity.OAuth.CallbackRequest
            ) async throws(any Swift.Error) -> Identity.Authentication.Response

        /// Get OAuth connection for current identity
        public var connection:
            (
                _ provider: String
            ) async throws(any Swift.Error) -> Identity.OAuth.Connection?

        /// Disconnect OAuth provider
        public var disconnect:
            (
                _ provider: String
            ) async throws(any Swift.Error) -> Void

        /// Get a valid OAuth access token for API usage
        /// This method handles token refresh automatically if supported by provider
        /// Returns nil if provider doesn't store tokens or token unavailable
        public var getValidToken:
            (
                _ provider: String
            ) async throws(any Swift.Error) -> String?

        /// Get all OAuth connections for current identity
        public var getAllConnections:
            () async throws(any Swift.Error) -> [Identity.OAuth.Connection]

    }
}
