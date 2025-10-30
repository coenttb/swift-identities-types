//
//  Identity.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2024.
//

import CasePaths
import TypesFoundation

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
  @CasePathable
  @dynamicMemberLookup
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

extension Identity.API {
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
  public struct Router: ParserPrinter, Sendable {

    public init() {}

    /// The main routing logic composition.
    ///
    /// Routes are defined using the `OneOf` parser to match incoming requests
    /// against all possible API endpoints. Each endpoint category has its own
    /// sub-router that handles the specific routing logic.
    public var body: some URLRouting.Router<Identity.API> {
      OneOf {
        URLRouting.Route(.case(Identity.API.authenticate)) {
          Path.authenticate
          Identity.Authentication.API.Router()
        }

        URLRouting.Route(.case(Identity.API.reauthorize)) {
          Path.reauthorize
          Identity.Reauthorization.API.Router()
        }

        URLRouting.Route(.case(Identity.API.create)) {
          Path.create
          Identity.Creation.API.Router()
        }

        URLRouting.Route(.case(Identity.API.delete)) {
          Path.delete
          Identity.Deletion.API.Router()
        }

        URLRouting.Route(.case(Identity.API.logout)) {
          Path.logout
          Identity.Logout.API.Router()
        }

        URLRouting.Route(.case(Identity.API.email)) {
          Path.email
          Identity.Email.API.Router()
        }

        URLRouting.Route(.case(Identity.API.password)) {
          Path.password
          Identity.Password.API.Router()
        }

        URLRouting.Route(.case(Identity.API.mfa)) {
          Path.mfa
          Identity.MFA.API.Router()
        }

        URLRouting.Route(.case(Identity.API.oauth)) {
          Path.oauth
          Identity.OAuth.API.Router()
        }
      }
    }
  }
}
