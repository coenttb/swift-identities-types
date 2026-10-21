//
//  Identity.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2024.
//

import Case_Macro
import Coder
import HTTP
import HTTP_Router

extension Identity {
    /// A comprehensive set of identity management API endpoints.
    ///
    /// `API` defines the complete set of identity-related operations available through the REST API,
    /// aggregating all domain-specific APIs following the domain-first pattern.
    ///
    /// This is an aggregation facade that allows both:
    /// - Legacy access pattern: `Identity.Authentication.API(...)`
    /// - New domain-first pattern: `Identity.Authentication.API.credentials(...)`
    ///
    /// The API supports the following operations:
    /// - Authentication and session management
    /// - Identity creation and deletion
    /// - Password operations (reset, change)
    /// - Email management and verification
    /// - Multi-factor authentication
    /// - OAuth provider integration
    ///
    /// Example of defining an API route:
    /// ```swift
    /// switch api {
    /// case .authenticate(let authenticate):
    ///   // Handle authentication request
    /// case .create(let create):
    ///   // Handle identity creation
    /// }
    /// ```
    @Prisms
    @Folds
    @Cases
    public enum API: Equatable, Sendable {
        /// Handles user authentication via credentials, tokens, or API keys
        case authenticate(Identity.Authentication.API)

        /// Re-authenticates a user for sensitive operations
        case reauthorize(Identity.Reauthorization.API)

        /// Manages new identity creation and verification
        case create(Identity.Creation.API)

        /// Handles identity deletion requests and confirmation
        case delete(Identity.Deletion.API)

        /// Manages logout operations (current session or all sessions)
        case logout(Identity.Logout.API)

        /// Manages email operations like change and verification
        case email(Identity.Email.API)

        /// Handles password-related operations like reset and change
        case password(Identity.Password.API)

        /// Manages multi-factor authentication operations
        case mfa(Identity.MFA.API)

        /// Manages OAuth provider authentication
        case oauth(Identity.OAuth.API)
    }
}

extension Identity.API {
    public static let logout: Self = .logout(.current)
}

extension Identity.API: HTTP.Routable {
    /// A type-safe router for mapping URLs to Identity API endpoints.
    ///
    /// The router uses parser-printer composition to define bidirectional mappings between
    /// URLs and API endpoints. It handles both parsing incoming requests to API cases and
    /// printing API cases to URLs.
    ///
    /// All routes follow RESTful conventions:
    /// - Authentication: `/authenticate/*`
    /// - Identity creation: `/create/*`
    /// - Password operations: `/password/*`
    /// - Email operations: `/email/*`
    /// - MFA operations: `/mfa/*`
    /// - OAuth operations: `/oauth/*`
    public static var router: some HTTP.Router.`Protocol`<Identity.API> {
        Coder::Case(
            Identity.API.cases.authenticate.prism,
            Identity.API.cases.authenticate.fold,
            absent: .mismatch
        ) {
            HTTP.Segment.authenticate
            Identity.Authentication.API.router
        }

        Coder::Case(
            Identity.API.cases.reauthorize.prism,
            Identity.API.cases.reauthorize.fold,
            absent: .mismatch
        ) {
            HTTP.Segment.reauthorize
            Identity.Reauthorization.API.router
        }

        Coder::Case(
            Identity.API.cases.create.prism,
            Identity.API.cases.create.fold,
            absent: .mismatch
        ) {
            HTTP.Segment.create
            Identity.Creation.API.router
        }

        Coder::Case(
            Identity.API.cases.delete.prism,
            Identity.API.cases.delete.fold,
            absent: .mismatch
        ) {
            HTTP.Segment.delete
            Identity.Deletion.API.router
        }

        Coder::Case(
            Identity.API.cases.logout.prism,
            Identity.API.cases.logout.fold,
            absent: .mismatch
        ) {
            HTTP.Segment.logout
            Identity.Logout.API.router
        }

        Coder::Case(
            Identity.API.cases.email.prism,
            Identity.API.cases.email.fold,
            absent: .mismatch
        ) {
            HTTP.Segment.email
            Identity.Email.API.router
        }

        Coder::Case(
            Identity.API.cases.password.prism,
            Identity.API.cases.password.fold,
            absent: .mismatch
        ) {
            HTTP.Segment.password
            Identity.Password.API.router
        }

        Coder::Case(Identity.API.cases.mfa.prism, Identity.API.cases.mfa.fold, absent: .mismatch) {
            HTTP.Segment.mfa
            Identity.MFA.API.router
        }

        Coder::Case(
            Identity.API.cases.oauth.prism,
            Identity.API.cases.oauth.fold,
            absent: .mismatch
        ) {
            HTTP.Segment.oauth
            Identity.OAuth.API.router
        }
    }
}
