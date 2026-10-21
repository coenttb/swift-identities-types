//
//  Identity.OAuth.API.swift
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

extension Identity.OAuth {
    /// OAuth-related API endpoints
    @Prisms
    @Folds
    @Cases
    public enum API: Equatable, Sendable {
        /// Get list of available OAuth providers
        case providers

        /// Initiate OAuth authorization flow
        case authorize(provider: String)

        /// Handle OAuth callback with code and state
        case callback(Identity.OAuth.CallbackRequest)

        /// Get current OAuth connections
        case connections

        /// Disconnect an OAuth provider
        case disconnect(provider: String)
    }
}

extension Identity.OAuth.API: HTTP.Routable {
    /// Router for OAuth API endpoints
    public static var router: some HTTP.Router.`Protocol`<Identity.OAuth.API> {
        // GET /oauth/providers
        Coder::Case(
            Identity.OAuth.API.cases.providers.prism,
            Identity.OAuth.API.cases.providers.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("providers")
            HTTP.Segment.End()
        }

        // GET /oauth/authorize/:provider
        Coder::Case(
            Identity.OAuth.API.cases.authorize.prism,
            Identity.OAuth.API.cases.authorize.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("authorize")
            HTTP.Segment.Value<String>()
            HTTP.Segment.End()
        }

        // GET /oauth/callback
        Coder::Case(
            Identity.OAuth.API.cases.callback.prism,
            Identity.OAuth.API.cases.callback.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
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
            Identity.OAuth.API.cases.connections.prism,
            Identity.OAuth.API.cases.connections.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("connections")
            HTTP.Segment.End()
        }

        // DELETE /oauth/disconnect/:provider
        Coder::Case(
            Identity.OAuth.API.cases.disconnect.prism,
            Identity.OAuth.API.cases.disconnect.fold,
            absent: .mismatch
        ) {
            HTTP.Method.delete
            HTTP.Segment("disconnect")
            HTTP.Segment.Value<String>()
            HTTP.Segment.End()
        }
    }
}
