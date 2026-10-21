//
//  Identity.Deletion.Route.swift
//  swift-identities
//
//  Feature-based routing for Delete functionality
//

import Case_Macro
import Coder
import HTTP
import HTTP_Router

extension Identity.Deletion {
    /// Complete routing for identity deletion features including both API and View endpoints.
    ///
    /// This combines identity deletion functionality for:
    /// - API endpoints (backend operations)
    /// - View endpoints (frontend pages)
    ///
    /// Usage:
    /// ```swift
    /// let route = Identity.Deletion.Route.api(.request(...))
    /// let viewRoute = Identity.Deletion.Route.view(.request)
    /// ```
    @Prisms
    @Folds
    @Cases
    public enum Route: Equatable, Sendable {
        /// API endpoints for deletion operations
        case api(API)

        /// View endpoints for deletion pages
        case view(View)
    }
}

extension Identity.Deletion.Route: HTTP.Routable {
    /// Router for the complete Delete feature including both API and View routes.
    ///
    /// URL structure:
    /// - API routes: `/api/delete/...`
    /// - View routes: `/delete`
    public static var router: some HTTP.Router.`Protocol`<Identity.Deletion.Route> {
        // API routes under /api prefix
        Coder::Case(
            Identity.Deletion.Route.cases.api.prism,
            Identity.Deletion.Route.cases.api.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("api")
            HTTP.Segment("delete")
            Identity.Deletion.API.router
        }

        // View routes (no /api prefix)
        Coder::Case(
            Identity.Deletion.Route.cases.view.prism,
            Identity.Deletion.Route.cases.view.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("delete")
            Identity.Deletion.View.router
        }
    }
}
