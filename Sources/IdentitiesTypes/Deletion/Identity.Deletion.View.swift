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
    /// View routes for identity deletion pages.
    ///
    /// Provides frontend routes for the deletion flow.
    @Prisms
    @Folds
    @Cases
    public enum View: Equatable, Sendable {
        /// Identity deletion request page
        case request

        // Could add confirmation or status pages in the future:
        // case confirm
        // case pending
    }
}

extension Identity.Deletion.View: HTTP.Routable {
    /// Router for deletion view endpoints.
    ///
    /// Maps view routes to their URL paths:
    /// - Request: `/delete` (main deletion page)
    public static var router: some HTTP.Router.`Protocol`<Identity.Deletion.View> {
        Coder::Case(
            Identity.Deletion.View.cases.request.prism,
            Identity.Deletion.View.cases.request.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment.End()
        }
    }
}
