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
import Pair

extension Identity.Creation {
    /// View routes for identity creation pages.
    ///
    /// Provides frontend routes for:
    /// - Creation request form
    /// - Email verification page
    @Prisms
    @Folds
    @Cases
    public enum View: Equatable, Sendable {
        /// Identity creation request page
        case request

        /// Email verification page with token and email
        case verify(Identity.Creation.Verification)

        public static let verify: Self = .verify(.init())
    }
}

extension Identity.Creation.View: HTTP.Routable {
    /// Router for creation view endpoints.
    ///
    /// Maps view routes to their URL paths:
    /// - Request: `/create/request`
    /// - Verify: `/create/verify`
    public static var router: some HTTP.Router.`Protocol`<Identity.Creation.View> {
        Coder::Case(
            Identity.Creation.View.cases.request.prism,
            Identity.Creation.View.cases.request.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("request")
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.Creation.View.cases.verify.prism,
            Identity.Creation.View.cases.verify.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("verify")

            Coder::Coder(
                { Identity.Creation.Verification(token: $0.first, email: $0.second) },
                from: { Pair($0.token, $0.email) }
            ) {
                HTTP.Query.Field<String>(
                    Identity.Creation.Verification.CodingKeys.token.rawValue,
                    default: ""
                )
                HTTP.Query.Field<String>(
                    Identity.Creation.Verification.CodingKeys.email.rawValue,
                    default: ""
                )
            }
            HTTP.Segment.End()
        }
    }
}
