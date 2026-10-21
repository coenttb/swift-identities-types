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
    /// View routes for email management pages.
    ///
    /// Provides frontend routes for email-related operations.
    @Prisms
    @Folds
    @Cases
    public enum View: Equatable, Sendable {
        /// Email change flow views
        case change(Change)

        /// Email change view endpoints
        @Prisms
        @Folds
        @Cases
        public enum Change: Equatable, Sendable {
            /// Email change request page
            case request

            /// Email change confirmation page with token
            case confirm(Identity.Email.Change.Confirmation)

            /// Reauthorization page for email change
            case reauthorization

            public static let confirm: Self = .confirm(.init())
        }
    }
}

extension Identity.Email.View: HTTP.Routable {
    /// Router for email view endpoints.
    ///
    /// Maps view routes to their URL paths:
    /// - Change flow: `/email/change/...`
    public static var router: some HTTP.Router.`Protocol`<Identity.Email.View> {
        Coder::Case(
            Identity.Email.View.cases.change.prism,
            Identity.Email.View.cases.change.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("change")
            Identity.Email.View.Change.router
        }
    }
}

extension Identity.Email.View.Change: HTTP.Routable {
    /// Router for email change view endpoints.
    ///
    /// Maps view routes to their URL paths:
    /// - Request: `/email/change/request`
    /// - Confirm: `/email/change/confirm`
    /// - Reauthorization: `/email/change/reauthorization`
    public static var router: some HTTP.Router.`Protocol`<Identity.Email.View.Change> {
        Coder::Case(
            Identity.Email.View.Change.cases.request.prism,
            Identity.Email.View.Change.cases.request.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("request")
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.Email.View.Change.cases.confirm.prism,
            Identity.Email.View.Change.cases.confirm.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("confirm")
            Identity.Email.Change.Confirmation.router
        }

        Coder::Case(
            Identity.Email.View.Change.cases.reauthorization.prism,
            Identity.Email.View.Change.cases.reauthorization.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment.End()
        }
    }
}
