//
//  Identity.Authentication.Route.swift
//  swift-identities
//
//  Feature-based routing for Authentication functionality
//

import CasePaths
import ServerFoundation

extension Identity.Authentication {
    /// Complete routing for authentication features including both API and View endpoints.
    ///
    /// This combines authentication functionality for:
    /// - API endpoints (backend operations)
    /// - View endpoints (frontend pages)
    ///
    /// Usage:
    /// ```swift
    /// let route = Identity.Authentication.Route.api(.credentials(...))
    /// let viewRoute = Identity.Authentication.Route.view(.credentials)
    /// ```
    @CasePathable
    @dynamicMemberLookup
    public enum Route: Sendable, Hashable, Codable {
        /// API endpoints for authentication operations
        case api(API)
        
        /// View endpoints for authentication pages
        case view(View)
    }
}

extension Identity.Authentication {
    /// API endpoints for authentication.
    ///
    /// Inherits from the existing Identity.API.Authenticate structure
    /// to maintain backward compatibility while enabling feature-based organization.
    public typealias API = Identity.API.Authenticate
}

extension Identity.Authentication {
    /// View routes for authentication pages.
    ///
    /// Provides frontend routes for different authentication methods.
    @CasePathable
    @dynamicMemberLookup
    public enum View: Sendable, Hashable, Codable  {
        /// Credentials-based login page (username/password)
        case credentials
        
        // Future authentication methods can be added here:
        // case oauth(provider: OAuthProvider)
        // case sso
        // case passwordless
    }
}

extension Identity.Authentication.Route {
    /// Router for the complete Authenticate feature including both API and View routes.
    ///
    /// URL structure:
    /// - API routes: `/api/authenticate/...`
    /// - View routes: `/login` (using common web convention)
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.Authentication.Route> {
            OneOf {
                // API routes under /api prefix
                URLRouting.Route(.case(Identity.Authentication.Route.api)) {
                    Path { "api" }
                    Path { "authenticate" }
                    Identity.Authentication.API.Router()
                }
                
                // View routes use /login for better UX
                URLRouting.Route(.case(Identity.Authentication.Route.view)) {
                    Identity.Authentication.View.Router()
                }
            }
        }
    }
}

extension Identity.Authentication.View {
    /// Router for authentication view endpoints.
    ///
    /// Maps view routes to their URL paths:
    /// - Credentials: `/login` or `/credentials` (both map to same page)
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.Authentication.View> {
            // Support both /login and /credentials paths
            OneOf {
                URLRouting.Route(.case(Identity.Authentication.View.credentials)) {
                    Path { "login" }
                }
                
                URLRouting.Route(.case(Identity.Authentication.View.credentials)) {
                    Path { "credentials" }
                }
            }
            
            // Future auth methods would be added here:
            // URLRouting.Route(.case(Identity.Authentication.View.oauth)) {
            //     Path { "oauth" }
            //     OAuthProvider.Router()
            // }
        }
    }
}
