//
//  Identity.OAuth.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2025.
//

import TypesFoundation

extension Identity {
    /// Namespace for OAuth-related functionality within the Identity system.
    public struct OAuth: @unchecked Sendable {
        public var client: Identity.OAuth.Client
        public var router: any URLRouting.Router<Identity.OAuth.Route>
        
        public init(
            client: Identity.OAuth.Client,
            router: any URLRouting.Router<Identity.OAuth.Route> = Identity.OAuth.Route.Router()
        ) {
            self.client = client
            self.router = router
        }
    }
}

extension Identity.OAuth {
    /// OAuth connection information
    public struct Connection: Codable, Sendable {
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


extension Identity.OAuth {
    /// Protocol defining an OAuth provider's capabilities
    public protocol Provider: Sendable {
        /// Unique identifier for this provider (e.g., "github", "google")
        var identifier: String { get }
        
        /// Display name for UI purposes
        var displayName: String { get }
        
        /// Whether this provider requires token storage for API access
        /// If false, tokens are only used for authentication and not stored
        /// If true, tokens are encrypted and stored for later API usage
        var requiresTokenStorage: Bool { get }
        
        /// Whether this provider supports token refresh
        var supportsRefresh: Bool { get }
        
        /// Generate authorization URL for OAuth flow
        func authorizationURL(state: String, redirectURI: String) async throws -> URL
        
        /// Exchange authorization code for tokens
        func exchangeCode(_ code: String, redirectURI: String) async throws -> TokenResponse
        
        /// Get user information using access token
        func getUserInfo(accessToken: String) async throws -> UserInfo
        
        /// Refresh access token if supported (optional)
        func refreshToken(_ refreshToken: String) async throws -> TokenResponse?
    }
    
    // MARK: - Default Implementations
    
    
    
    /// OAuth token response from provider
    public struct TokenResponse: Codable, Equatable, Sendable {
        public let accessToken: String
        public let refreshToken: String?
        public let expiresIn: Int?
        public let scope: String?
        public let tokenType: String
        
        public init(
            accessToken: String,
            refreshToken: String? = nil,
            expiresIn: Int? = nil,
            scope: String? = nil,
            tokenType: String = "Bearer"
        ) {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
            self.expiresIn = expiresIn
            self.scope = scope
            self.tokenType = tokenType
        }
    }
    
    /// Generic user information from OAuth provider
    public struct UserInfo: Codable, Sendable {
        /// Unique user ID from the provider
        public let id: String
        
        /// User's email address
        public let email: EmailAddress?
        
        /// Whether the email is verified by the provider
        public let emailVerified: Bool?
        
        /// User's display name
        public let name: String?
        
        /// User's username/handle
        public let username: String?
        
        /// Profile picture URL
        public let avatarURL: String?
        
        /// Raw provider-specific data
        public let rawData: Data
        
        public init(
            id: String,
            email: EmailAddress? = nil,
            emailVerified: Bool? = nil,
            name: String? = nil,
            username: String? = nil,
            avatarURL: String? = nil,
            rawData: Data
        ) {
            self.id = id
            self.email = email
            self.emailVerified = emailVerified
            self.name = name
            self.username = username
            self.avatarURL = avatarURL
            self.rawData = rawData
        }
    }
    
    /// OAuth callback request data sent by the provider.
    ///
    /// This type represents the data sent back by OAuth providers in the callback URL
    /// after user authorization. It's used for external API routes and views.
    public struct CallbackRequest: Codable, Equatable, Sendable {
        /// The OAuth provider identifier (e.g., "github", "google")
        public let provider: String
        
        /// The authorization code returned by the OAuth provider.
        /// This code must be exchanged for access and refresh tokens.
        public let code: String
        
        /// The state parameter for CSRF protection.
        /// This should match the state originally sent in the authorization request.
        public let state: String
        
        /// The redirect URI if provided by the OAuth provider (rarely sent back).
        /// Most providers don't include this in the callback.
        public let redirectURI: String?
        
        /// Creates a new OAuth callback request instance.
        ///
        /// - Parameters:
        ///   - provider: The OAuth provider identifier
        ///   - code: The authorization code from the provider
        ///   - state: The state parameter for CSRF protection
        ///   - redirectURI: The redirect URI if provided (optional)
        public init(
            provider: String,
            code: String,
            state: String,
            redirectURI: String? = nil
        ) {
            self.provider = provider
            self.code = code
            self.state = state
            self.redirectURI = redirectURI
        }
    }
    
    /// Internal OAuth token exchange request.
    ///
    /// This type is used internally for exchanging authorization codes for tokens.
    /// It contains all required data including the redirect URI retrieved from state.
    /// This type is never exposed in public APIs.
    public struct TokenExchangeRequest: Codable, Equatable, Sendable {
        /// The OAuth provider identifier (e.g., "github", "google")
        public let provider: String
        
        /// The authorization code to exchange for tokens.
        public let code: String
        
        /// The redirect URI that was used in the authorization request.
        /// Required for the token exchange with the OAuth provider.
        public let redirectURI: String
        
        /// Creates a new token exchange request.
        ///
        /// - Parameters:
        ///   - provider: The OAuth provider identifier
        ///   - code: The authorization code to exchange
        ///   - redirectURI: The redirect URI used in authorization
        public init(
            provider: String,
            code: String,
            redirectURI: String
        ) {
            self.provider = provider
            self.code = code
            self.redirectURI = redirectURI
        }
    }
    
    
    /// OAuth state for CSRF protection
    public struct State: Codable, Sendable {
        public let value: String
        public let provider: String
        public let redirectURI: String
        public let createdAt: Date
        public let expiresAt: Date
        
        public init(
            value: String,
            provider: String,
            redirectURI: String,
            createdAt: Date = Date(),
            expiresAt: Date = Date().addingTimeInterval(600) // 10 minutes
        ) {
            self.value = value
            self.provider = provider
            self.redirectURI = redirectURI
            self.createdAt = createdAt
            self.expiresAt = expiresAt
        }
        
        public var isExpired: Bool {
            Date() > expiresAt
        }
    }
}

/// Default implementations for OAuth Provider protocol
public extension Identity.OAuth.Provider {
    /// By default, providers don't require token storage (authentication only)
    var requiresTokenStorage: Bool { false }
    
    /// By default, providers don't support refresh
    var supportsRefresh: Bool { false }
    
    /// Default implementation returns nil (no refresh support)
    func refreshToken(_ refreshToken: String) async throws -> Identity.OAuth.TokenResponse? {
        return nil
    }
}
