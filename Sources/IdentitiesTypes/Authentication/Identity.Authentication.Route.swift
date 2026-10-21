//
//  Identity.Authentication.Route.swift
//  swift-identities
//
//  Feature-based routing for Authentication functionality
//

import Case_Macro
import Coder
import HTTP
import HTTP_Router

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
    @Prisms
    @Folds
    @Cases
    public enum Route: Sendable, Hashable, Codable {
        /// API endpoints for authentication operations
        case api(Identity.Authentication.API)

        /// View endpoints for authentication pages
        case view(Identity.Authentication.View)
    }
}

extension Identity.Authentication.Route: HTTP.Routable {
    /// Router for the complete Authenticate feature including both API and View routes.
    ///
    /// URL structure:
    /// - API routes: `/api/authenticate/...`
    /// - View routes: `/login` (using common web convention)
    public static var router: some HTTP.Router.`Protocol`<Identity.Authentication.Route> {
        // API routes under /api prefix
        Coder::Case(
            Identity.Authentication.Route.cases.api.prism,
            Identity.Authentication.Route.cases.api.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("api")
            HTTP.Segment("authenticate")
            Identity.Authentication.API.router
        }

        // View routes use /login for better UX
        Coder::Case(
            Identity.Authentication.Route.cases.view.prism,
            Identity.Authentication.Route.cases.view.fold,
            absent: .mismatch
        ) {
            Identity.Authentication.View.router
        }
    }
}
