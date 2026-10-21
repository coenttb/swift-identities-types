//
//  Identity.Reauthorization.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 05/02/2025.
//

import Case_Macro
import Coder
import HTTP
import HTTP_Router

extension Identity {
    /// Namespace for reauthorization functionality within the Identity system.
    ///
    /// Reauthorization is required for sensitive operations that need to verify
    /// the user's identity beyond their existing session.

    public struct Reauthorization: @unchecked Sendable {
        public var client: Identity.Reauthorization.Client

        public init(
            client: Identity.Reauthorization.Client
        ) {
            self.client = client
        }
    }
}

extension Identity.Reauthorization {
    @Prisms
    @Folds
    @Cases
    public enum Route: Sendable, Equatable {
        case api(Identity.Reauthorization.API)
    }
}

extension Identity.Reauthorization.Route: HTTP.Routable {
    /// Routes reauthorization requests to their appropriate handlers.
    ///
    /// Handles reauthorization endpoint for sensitive operations.
    public static var router: some HTTP.Router.`Protocol`<Identity.Reauthorization.Route> {
        Coder::Case(
            Identity.Reauthorization.Route.cases.api.prism,
            Identity.Reauthorization.Route.cases.api.fold,
            absent: .mismatch
        ) {
            HTTP.Segment.api
            HTTP.Segment.reauthorize
            Identity.Reauthorization.API.router
        }
    }
}
