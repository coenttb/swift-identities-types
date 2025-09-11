//
//  Identity.Authentication.Route.swift
//  swift-identities
//
//  Feature-based routing for Authentication functionality
//

import CasePaths
import TypesFoundation

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
        case api(Identity.Authentication.API)
        
        /// View endpoints for authentication pages
        case view(Identity.Authentication.View)
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
