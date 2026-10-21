//
//  Identity.OAuth.Route.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2025.
//

import Case_Macro
import Coder
import Foundation
import HTTP
import HTTP_Router

extension Identity.OAuth {
    /// OAuth-specific routes
    @Prisms
    @Folds
    @Cases
    public enum Route: Equatable, Sendable {
        case api(Identity.OAuth.API)
        case view(Identity.View.OAuth)
    }
}

extension Identity.OAuth.Route: HTTP.Routable {
    /// Router for OAuth routes
    public static var router: some HTTP.Router.`Protocol`<Identity.OAuth.Route> {
        // API routes
        Coder::Case(
            Identity.OAuth.Route.cases.api.prism,
            Identity.OAuth.Route.cases.api.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("api")
            HTTP.Segment("oauth")
            Identity.OAuth.API.router
        }

        // View routes
        Coder::Case(
            Identity.OAuth.Route.cases.view.prism,
            Identity.OAuth.Route.cases.view.fold,
            absent: .mismatch
        ) {
            Identity.View.OAuth.router
        }
    }
}
