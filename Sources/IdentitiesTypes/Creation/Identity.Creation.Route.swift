//
//  Identity.Creation.Route.swift
//  swift-identities
//
//  Feature-based routing for Create functionality
//

import Case_Macro
import Coder
import HTTP
import HTTP_Router

extension Identity.Creation {
    /// Complete routing for identity creation features including both API and View endpoints.
    ///
    /// This combines identity creation functionality for:
    /// - API endpoints (backend operations)
    /// - View endpoints (frontend pages)
    ///
    /// Usage:
    /// ```swift
    /// let route = Identity.Creation.Route.api(.request(...))
    /// let viewRoute = Identity.Creation.Route.view(.request)
    /// ```
    @Prisms
    @Folds
    @Cases
    public enum Route: Equatable, Sendable {
        /// API endpoints for creation operations
        case api(Identity.Creation.API)

        /// View endpoints for creation pages
        case view(Identity.Creation.View)
    }
}

extension Identity.Creation.Route: HTTP.Routable {
    /// Router for the complete Create feature including both API and View routes.
    ///
    /// URL structure:
    /// - API routes: `/api/create/...`
    /// - View routes: `/create/...`
    public static var router: some HTTP.Router.`Protocol`<Identity.Creation.Route> {
        // API routes under /api prefix
        Coder::Case(
            Identity.Creation.Route.cases.api.prism,
            Identity.Creation.Route.cases.api.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("api")
            HTTP.Segment("create")
            Identity.Creation.API.router
        }

        // View routes (no /api prefix)
        Coder::Case(
            Identity.Creation.Route.cases.view.prism,
            Identity.Creation.Route.cases.view.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("create")
            Identity.Creation.View.router
        }
    }
}
