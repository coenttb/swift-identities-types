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
            // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            (any Identity.OAuth.Provider) async throws(Identity.OAuth.Client.Error) -> Void
        // swiftlint:enable no_any_protocol_existential

        /// Get a registered OAuth provider by identifier
        public var provider:
            // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            (_ identifier: String) async throws(any Swift.Error) -> (any Identity.OAuth.Provider)?
        // swiftlint:enable no_any_protocol_existential

        // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
        /// Get all registered OAuth providers
        public var providers: () async throws(any Swift.Error) -> [any Identity.OAuth.Provider]
        // swiftlint:enable no_any_protocol_existential

        /// Generate authorization URL for OAuth flow
        public var authorizationURL:
            (
                _ provider: String,
                _ redirectURI: String
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> URL
        // swiftlint:enable no_any_protocol_existential

        /// Handle OAuth callback and exchange code for tokens
        public var callback:
            (
                _ callbackRequest: Identity.OAuth.CallbackRequest
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> Identity.Authentication.Response
        // swiftlint:enable no_any_protocol_existential

        /// Get OAuth connection for current identity
        public var connection:
            (
                _ provider: String
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> Identity.OAuth.Connection?
        // swiftlint:enable no_any_protocol_existential

        /// Disconnect OAuth provider
        public var disconnect:
            (
                _ provider: String
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> Void
        // swiftlint:enable no_any_protocol_existential

        /// Get a valid OAuth access token for API usage
        /// This method handles token refresh automatically if supported by provider
        /// Returns nil if provider doesn't store tokens or token unavailable
        public var getValidToken:
            (
                _ provider: String
                    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            ) async throws(any Swift.Error) -> String?
        // swiftlint:enable no_any_protocol_existential

        /// Get all OAuth connections for current identity
        public var getAllConnections:
            // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            () async throws(any Swift.Error) -> [Identity.OAuth.Connection]
        // swiftlint:enable no_any_protocol_existential

    }
}
