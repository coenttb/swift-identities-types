//
//  Identity.View.OAuth.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2025.
//

import Case_Macro
import Coder
import Foundation
import HTTP
import HTTP_Router
import Pair

extension Identity.View {
    /// OAuth view routes for UI pages
    @Prisms
    @Folds
    @Cases
    public enum OAuth: Equatable, Sendable {
        /// OAuth login page showing available providers
        case login

        /// OAuth callback handling page
        case callback(Identity.OAuth.CallbackRequest)

        /// OAuth connection management page
        case connections

        /// OAuth error page
        case error(String)
    }
}

extension Identity.View.OAuth: HTTP.Routable {
    /// Router for OAuth view routes
    public static var router: some HTTP.Router.`Protocol`<Identity.View.OAuth> {
        // GET /oauth/login
        Coder::Case(
            Identity.View.OAuth.cases.login.prism,
            Identity.View.OAuth.cases.login.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("oauth")
            HTTP.Segment("login")
            HTTP.Segment.End()
        }

        // GET /oauth/callback
        Coder::Case(
            Identity.View.OAuth.cases.callback.prism,
            Identity.View.OAuth.cases.callback.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("oauth")
            HTTP.Segment("callback")

            Coder::Coder(
                { values in
                    Identity.OAuth.CallbackRequest(
                        provider: values.first.first.first,
                        code: values.first.first.second,
                        state: values.first.second,
                        redirectURI: values.second
                    )
                },
                from: { Pair(Pair(Pair($0.provider, $0.code), $0.state), $0.redirectURI) }
            ) {
                HTTP.Query.Field<String>("provider", default: "github")
                HTTP.Query.Field<String>("code")
                HTTP.Query.Field<String>("state")
                HTTP.Query.Field<String>.Optional("redirect_uri")
            }
            HTTP.Segment.End()
        }

        // GET /oauth/connections
        Coder::Case(
            Identity.View.OAuth.cases.connections.prism,
            Identity.View.OAuth.cases.connections.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("oauth")
            HTTP.Segment("connections")
            HTTP.Segment.End()
        }

        // GET /oauth/error
        Coder::Case(
            Identity.View.OAuth.cases.error.prism,
            Identity.View.OAuth.cases.error.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("oauth")
            HTTP.Segment("error")
            HTTP.Query.Field<String>("message")
            HTTP.Segment.End()
        }
    }
}
