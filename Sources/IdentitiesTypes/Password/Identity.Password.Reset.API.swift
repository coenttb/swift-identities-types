//
//  Identity.Password.Reset.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Case_Macro
import Coder
import HTTP
import HTTP_Router

extension Identity.Password.Reset {
    /// Password reset API endpoints.
    @Prisms
    @Folds
    @Cases
    public enum API: Equatable, Sendable {
        /// Request a password reset via email
        case request(Identity.Password.Reset.Request)

        /// Confirm password reset with token and new password
        case confirm(Identity.Password.Reset.Confirm)
    }
}

extension Identity.Password.Reset.API: HTTP.Routable {
    /// Router for password reset endpoints.
    public static var router: some HTTP.Router.`Protocol`<Identity.Password.Reset.API> {
        Coder::Case(
            Identity.Password.Reset.API.cases.request.prism,
            Identity.Password.Reset.API.cases.request.fold,
            absent: .mismatch
        ) {
            Identity.Password.Reset.Request.router
        }

        Coder::Case(
            Identity.Password.Reset.API.cases.confirm.prism,
            Identity.Password.Reset.API.cases.confirm.fold,
            absent: .mismatch
        ) {
            Identity.Password.Reset.Confirm.router
        }
    }
}
