////
////  Identity.Client.swift
////  swift-identities
////
////  Created by Coen ten Thije Boonkkamp on 11/09/2024.
////
//
//import Dependencies
//import DependenciesMacros
//import EmailAddress
//import Foundation
//import TypesFoundation
//
//extension Identity {
//    /// A client interface for interacting with identity and authentication services.
//    ///
//    /// The `Client` type provides a high-level API for performing identity-related operations in a
//    /// type-safe manner. It aggregates all domain-specific clients following the domain-first pattern.
//    ///
//    /// This is an aggregation facade that composes all domain clients together, allowing both:
//    /// - Legacy access pattern: `@Dependency(\.identity.client).authenticate`
//    /// - New domain-first pattern: `@Dependency(\.identity.authenticate.client)`
//    ///
//    /// You can use the client to perform common operations like logging in:
//    /// ```swift
//    /// @Dependency(\.identity.client) var client
//    ///
//    /// // Login with username/password
//    /// let response = try await client.login(
//    ///   username: "user@example.com",
//    ///   password: "password123"
//    /// )
//    ///
//    /// // Or login with an access token
//    /// try await client.login(accessToken: "jwt-token-string")
//    /// ```
//    ///
//    /// The client provides interfaces for:
//    /// - Identity authentication (credentials, tokens, API keys)
//    /// - Identity creation and deletion
//    /// - Password management
//    /// - Email verification and updates
//    /// - Session management
//    ///
//    /// Each operation is provided through a dedicated domain interface:
//    /// - ``authenticate`` for authentication operations
//    /// - ``create`` for identity creation
//    /// - ``email`` for email management
//    /// - ``password`` for password operations
//    /// - ``delete`` for identity deletion
//    @DependencyClient
//    public struct Client: @unchecked Sendable {
//        /// Interface for all authentication-related operations
//        public var authenticate: Identity.Authentication.Client = .init()
//
//        /// Interface for logout operations (current session or all sessions)
//        public var logout: Identity.Logout.Client = .init()
//
//        /// Re-authenticates the current user for sensitive operations
//        ///
//        /// - Parameter password: The user's current password
//        /// - Returns: A JWT token for the re-authenticated session
//        @DependencyEndpoint
//        public var reauthorize: (_ password: String) async throws -> JWT
//
//        /// Interface for identity creation operations
//        public var create: Identity.Creation.Client = .init()
//
//        /// Interface for identity deletion operations
//        public var delete: Identity.Deletion.Client = .init()
//
//
//        /// Interface for password management operations
//        public var password: Identity.Password.Client = .init(reset: .init(), change: .init())
//        
//        /// Optional multi-factor authentication support
//        /// If nil, MFA is not available
//        public var mfa: Identity.MFA.Client? = nil
//        
//        /// Optional OAuth provider support
//        /// If nil, OAuth is not available
//        public var oauth: Identity.OAuth.Client? = nil
//    }
//}
//

