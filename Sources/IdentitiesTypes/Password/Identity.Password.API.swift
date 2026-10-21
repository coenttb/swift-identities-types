//
//  Identity.Password.API.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

import Case_Macro
import Coder
import HTTP
import HTTP_Router

extension Identity.Password {
    /// Password management endpoints for handling password changes and resets.
    ///
    /// Supports two primary password operations:
    /// 1. Password reset (forgotten password flow)
    /// 2. Password change (authenticated user changing their password)
    ///
    /// Example of initiating a password reset:
    /// ```swift
    /// // Request password reset
    /// let reset = Identity.Password.API.reset(
    ///   .request(.init(email: "user@example.com"))
    /// )
    ///
    /// // Change password while authenticated
    /// let change = Identity.Password.API.change(
    ///   .request(.init(
    ///     currentPassword: "old-password",
    ///     newPassword: "new-password"
    ///   ))
    /// )
    /// ```
    @Prisms
    @Folds
    @Cases
    public enum API: Equatable, Sendable {
        /// Password reset flow for forgotten passwords
        case reset(Identity.Password.Reset.API)

        /// Password change flow for authenticated users
        case change(Identity.Password.Change.API)
    }
}

extension Identity.Password.API: HTTP.Routable {
    /// Routes password management requests to their appropriate handlers.
    ///
    /// Defines the URL structure for password operations:
    /// - Reset request: `POST /password/reset/request`
    /// - Reset confirmation: `POST /password/reset/confirm`
    /// - Password change: `POST /password/change/request`
    ///
    /// All endpoints expect form-encoded request bodies containing
    /// the necessary password operation data and enforce appropriate
    /// security measures.
    public static var router: some HTTP.Router.`Protocol`<Identity.Password.API> {
        Coder::Case(
            Identity.Password.API.cases.reset.prism,
            Identity.Password.API.cases.reset.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("reset")

            Identity.Password.Reset.API.router
        }

        Coder::Case(
            Identity.Password.API.cases.change.prism,
            Identity.Password.API.cases.change.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("change")

            Identity.Password.Change.API.router
        }
    }
}
