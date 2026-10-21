//
//  Identity.Password.Change.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Case_Macro
import Coder
import HTTP
import HTTP_Router

extension Identity.Password.Change {
    /// Password change API endpoints for authenticated users.
    @Prisms
    @Folds
    @Cases
    public enum API: Equatable, Sendable {
        /// Request a password change (requires current password)
        case request(Identity.Password.Change.Request)
    }
}

extension Identity.Password.Change.API: HTTP.Routable {
    /// Router for password change endpoints.
    public static var router: some HTTP.Router.`Protocol`<Identity.Password.Change.API> {
        Coder::Case(
            Identity.Password.Change.API.cases.request.prism,
            Identity.Password.Change.API.cases.request.fold,
            absent: .mismatch
        ) {
            Identity.Password.Change.Request.router
        }
    }
}
