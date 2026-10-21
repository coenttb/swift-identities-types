//
//  Identity.Email.Route.swift
//  swift-identities
//
//  Feature-based routing for Email functionality
//

import Case_Macro
import Coder
import HTTP
import HTTP_Router

extension Identity.Email {
    /// Complete routing for email management features including both API and View endpoints.
    ///
    /// This combines email management functionality for:
    /// - API endpoints (backend operations)
    /// - View endpoints (frontend pages)
    ///
    /// Usage:
    /// ```swift
    /// let route = Identity.Email.Route.api(.change(.request(...)))
    /// let viewRoute = Identity.Email.Route.view(.change(.request))
    /// ```
    @Prisms
    @Folds
    @Cases
    public enum Route: Equatable, Sendable {
        /// API endpoints for email operations
        case api(API)

        /// View endpoints for email pages
        case view(View)
    }
}

extension Identity.Email.Route: HTTP.Routable {
    /// Router for the complete Email feature including both API and View routes.
    ///
    /// URL structure:
    /// - API routes: `/api/email/...`
    /// - View routes: `/email/...`
    public static var router: some HTTP.Router.`Protocol`<Identity.Email.Route> {
        // API routes under /api prefix
        Coder::Case(
            Identity.Email.Route.cases.api.prism,
            Identity.Email.Route.cases.api.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("api")
            HTTP.Segment("email")
            Identity.Email.API.router
        }

        // View routes (no /api prefix)
        Coder::Case(
            Identity.Email.Route.cases.view.prism,
            Identity.Email.Route.cases.view.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("email")
            Identity.Email.View.router
        }
    }
}
