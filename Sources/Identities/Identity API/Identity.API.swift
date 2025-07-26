//
//  Identity.API.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2024.
//

import CasePaths
import Swift_Web

extension Identity {
    /// A comprehensive set of identity management API endpoints.
    ///
    /// `API` defines the complete set of identity-related operations available through the REST API,
    /// including authentication, identity management, and profile operations. Each case represents
    /// a distinct API endpoint category with its associated request/response types.
    ///
    /// The API supports the following operations:
    /// - Authentication and session management
    /// - Identity creation and deletion
    /// - Password operations (reset, change)
    /// - Email management and verification
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
        case authenticate(Identity.API.Authenticate)

        /// Re-authenticates a user for sensitive operations
        case reauthorize(Identity.API.Reauthorize)

        /// Manages new identity creation and verification
        case create(Identity.API.Create)

        /// Handles identity deletion requests and confirmation
        case delete(Identity.API.Delete)

        /// Terminates the current user session
        case logout

        /// Manages email operations like change and verification
        case email(Identity.API.Email)

        /// Handles password-related operations like reset and change
        case password(Identity.API.Password)
    }
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
   ///
   /// The router automatically handles:
   /// - Path components
   /// - HTTP methods
   /// - Request body parsing
   /// - Response serialization
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        /// The routing logic for all Identity API endpoints.
        ///
        /// Routes are composed using the `OneOf` parser-printer, which attempts to match
        /// incoming requests against each defined route in order. The first matching route
        /// determines how the request is handled.
        public var body: some URLRouting.Router<Identity.API> {
            OneOf {
                URLRouting.Route(.case(Identity.API.create)) {
                    Path.create
                    Identity.API.Create.Router()
                }

                URLRouting.Route(.case(Identity.API.delete)) {
                    Path.delete
                    Identity.API.Delete.Router()
                }

                URLRouting.Route(.case(Identity.API.authenticate)) {
                    Path.authenticate
                    Identity.API.Authenticate.Router()
                }

                URLRouting.Route(.case(Identity.API.logout)) {
                    Path.logout
                    Method.post
                }

                URLRouting.Route(.case(Identity.API.reauthorize)) {
                    Method.post
                    Path.reauthorize
                    Body(.form(Identity.API.Reauthorize.self, decoder: .identities))
                }

                URLRouting.Route(.case(Identity.API.password)) {
                    Path.password
                    Identity.API.Password.Router()
                }

                URLRouting.Route(.case(Identity.API.email)) {
                    Path.email
                    Identity.API.Email.Router()
                }
            }
        }
    }
}

extension Identity.API.Router: TestDependencyKey {
    /// A test implementation of the Identity API router.
    ///
    /// This router is used in test environments to verify routing logic without
    /// requiring a full server implementation.
    public static let testValue: AnyParserPrinter<URLRequestData, Identity.API> = Identity.API.Router().eraseToAnyParserPrinter()
}
