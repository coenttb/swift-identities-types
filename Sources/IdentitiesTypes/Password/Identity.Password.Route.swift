//
//  Identity.Password.Route.swift
//  swift-identities
//
//  Feature-based routing for Password functionality
//

import Case_Macro
import Coder
import HTTP
import HTTP_Router

extension Identity.Password {
    /// Complete routing for password-related features including both API and View endpoints.
    ///
    /// This combines password management functionality for:
    /// - API endpoints (backend operations)
    /// - View endpoints (frontend pages)
    ///
    /// Usage:
    /// ```swift
    /// let route = Identity.Password.Route.api(.reset(.request(...)))
    /// let viewRoute = Identity.Password.Route.view(.reset(.request))
    /// ```
    @Prisms
    @Folds
    @Cases
    public enum Route: Equatable, Sendable {
        /// API endpoints for password operations
        case api(API)

        /// View endpoints for password pages
        case view(View)
    }
}

extension Identity.Password {
    /// View routes for password-related pages.
    ///
    /// Provides frontend routes for:
    /// - Password reset flow (request and confirmation)
    /// - Password change flow for authenticated users
    @Prisms
    @Folds
    @Cases
    public enum View: Equatable, Sendable {
        /// Password reset view flow
        case reset(Reset)

        /// Password change view flow
        case change(Change)

        /// Password reset view endpoints
        @Prisms
        @Folds
        @Cases
        public enum Reset: Equatable, Sendable {
            /// Password reset request page
            case request

            /// Password reset confirmation page with token and new password
            case confirm(Identity.Password.Reset.Confirm)

            public static let confirm: Self = .confirm(.init())
        }

        /// Password change view endpoints
        @Prisms
        @Folds
        @Cases
        public enum Change: Equatable, Sendable {
            /// Password change request page
            case request
        }
    }
}

extension Identity.Password.Route: HTTP.Routable {
    /// Router for the complete Password feature including both API and View routes.
    ///
    /// URL structure:
    /// - API routes: `/api/password/...`
    /// - View routes: `/password/...`
    public static var router: some HTTP.Router.`Protocol`<Identity.Password.Route> {
        // API routes under /api prefix
        Coder::Case(
            Identity.Password.Route.cases.api.prism,
            Identity.Password.Route.cases.api.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("api")
            HTTP.Segment("password")
            Identity.Password.API.router
        }

        // View routes (no /api prefix)
        Coder::Case(
            Identity.Password.Route.cases.view.prism,
            Identity.Password.Route.cases.view.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("password")
            Identity.Password.View.router
        }
    }
}

extension Identity.Password.View: HTTP.Routable {
    /// Router for password view endpoints.
    ///
    /// Maps view routes to their URL paths:
    /// - Reset request: `/password/reset/request`
    /// - Reset confirm: `/password/reset/confirm`
    /// - Change request: `/password/change/request`
    public static var router: some HTTP.Router.`Protocol`<Identity.Password.View> {
        Coder::Case(
            Identity.Password.View.cases.reset.prism,
            Identity.Password.View.cases.reset.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("reset")
            Identity.Password.View.Reset.router
        }

        Coder::Case(
            Identity.Password.View.cases.change.prism,
            Identity.Password.View.cases.change.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("change")
            Identity.Password.View.Change.router
        }
    }
}

extension Identity.Password.View.Reset: HTTP.Routable {
    /// Router for password reset view endpoints.
    public static var router: some HTTP.Router.`Protocol`<Identity.Password.View.Reset> {
        Coder::Case(
            Identity.Password.View.Reset.cases.request.prism,
            Identity.Password.View.Reset.cases.request.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("request")
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.Password.View.Reset.cases.confirm.prism,
            Identity.Password.View.Reset.cases.confirm.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("confirm")
            Identity.Password.Reset.Confirm.router
        }
    }
}

extension Identity.Password.View.Change: HTTP.Routable {
    /// Router for password change view endpoints.
    public static var router: some HTTP.Router.`Protocol`<Identity.Password.View.Change> {
        Coder::Case(
            Identity.Password.View.Change.cases.request.prism,
            Identity.Password.View.Change.cases.request.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("request")
            HTTP.Segment.End()
        }
    }
}
