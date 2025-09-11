//
//  Identity.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//
import CasePaths
import Dependencies
import DependenciesMacros
import JWT
import TypesFoundation

/// A namespace for managing identity and authentication in a client-server architecture.
///
/// The Identity namespace provides a comprehensive set of tools for handling identity authentication
/// and identity management through both provider and consumer interfaces. It supports:
///
/// - Identity authentication via credentials, tokens, and API keys
/// - Identity creation and verification flows
/// - Password management (reset, change)
/// - Email management and verification
/// - Session management (login/logout)
///
/// Example of authenticating a user:
/// ```swift
/// let client = Identity.Client(...)
/// let response = try await client.login(
///   username: "user@example.com",
///   password: "password123"
/// )
/// ```
@DependencyClient
public struct Identity: @unchecked Sendable {
    /// Interface for all authentication-related operations
    public var authenticate: Identity.Authentication
    
    /// Interface for logout operations (current session or all sessions)
    public var logout: Identity.Logout
    
    /// Re-authenticates the current user for sensitive operations
    ///
    /// - Parameter password: The user's current password
    /// - Returns: A JWT token for the re-authenticated session
    public var reauthorize: Identity.Reauthorization
    
    /// Interface for identity creation operations
    public var create: Identity.Creation
    
    /// Interface for identity deletion operations
    public var delete: Identity.Deletion
    
    /// Interface for email management operations
    public var email: Identity.Email
    
    /// Interface for password management operations
    public var password: Identity.Password
    
    /// Optional multi-factor authentication support
    /// If nil, MFA is not available
    public var mfa: Identity.MFA?
    
    /// Optional OAuth provider support
    /// If nil, OAuth is not available
    public var oauth: Identity.OAuth?
    
    public init(
        authenticate: Identity.Authentication,
        logout: Identity.Logout,
        reauthorize: Identity.Reauthorization,
        create: Identity.Creation,
        delete: Identity.Deletion,
        email: Identity.Email,
        password: Identity.Password,
        mfa: Identity.MFA? = nil,
        oauth: Identity.OAuth? = nil
    ) {
        self.authenticate = authenticate
        self.logout = logout
        self.reauthorize = reauthorize
        self.create = create
        self.delete = delete
        self.email = email
        self.password = password
        self.mfa = mfa
        self.oauth = oauth
    }
}


extension DependencyValues {
    public var identity: Identity {
        get { self[Identity.self] }
        set { self[Identity.self] = newValue }
    }
}

extension Identity {
    public var router: Identity.Route.Router {
        Identity.Route.Router()
    }
}

