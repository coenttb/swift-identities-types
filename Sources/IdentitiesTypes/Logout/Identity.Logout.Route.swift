//
//  Identity.Logout.Route.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2025.
//

import Case_Macro
import Coder
import HTTP
import HTTP_Router

extension Identity.Logout {
    /// Routes for logout functionality.
    ///
    /// Logout is a simple operation with just a single endpoint.
    /// It's typically accessed as a GET request that clears authentication.
    @Prisms
    @Folds
    @Cases
    public enum Route: Equatable, Sendable {
        case api(Identity.Logout.API)
        case view
    }
}

extension Identity.Logout.Route: HTTP.Routable {
    /// Router for logout routes.
    ///
    /// Since logout is a simple endpoint with no sub-routes,
    /// this router doesn't need to match anything additional.
    public static var router: some HTTP.Router.`Protocol`<Identity.Logout.Route> {
        Coder::Case(
            Identity.Logout.Route.cases.api.prism,
            Identity.Logout.Route.cases.api.fold,
            absent: .mismatch
        ) {
            HTTP.Segment.logout
            Identity.Logout.API.router
        }

        Coder::Case(
            Identity.Logout.Route.cases.view.prism,
            Identity.Logout.Route.cases.view.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment.logout
            HTTP.Segment("view")
            HTTP.Segment.End()
        }
    }
}
