//
//  Identity.Logout.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Case_Macro
import Coder
import HTTP
import HTTP_Router

extension Identity.Logout {
    /// Logout operations for terminating user sessions.
    ///
    /// This enum provides different logout strategies:
    /// - `current`: Logs out only the current session
    /// - `all`: Logs out all sessions across all devices by incrementing sessionVersion
    @Prisms
    @Folds
    @Cases
    public enum API: Equatable, Sendable {
        /// Logs out the current session only
        case current

        /// Logs out all sessions for the user across all devices
        case all
    }
}

extension Identity.Logout.API: HTTP.Routable {
    /// Router for logout endpoints
    public static var router: some HTTP.Router.`Protocol`<Identity.Logout.API> {
        // POST /logout (current session)
        Coder::Case(
            Identity.Logout.API.cases.current.prism,
            Identity.Logout.API.cases.current.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment.End()
        }

        // POST /logout/all (all sessions)
        Coder::Case(
            Identity.Logout.API.cases.all.prism,
            Identity.Logout.API.cases.all.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("all")
            HTTP.Method.post
            HTTP.Segment.End()
        }
    }
}
