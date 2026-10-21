//
//  Identity.Deletion.API.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

import Case_Macro
import Coder
import HTTP
import HTTP_Router

extension Identity.Deletion {
    /// Identity deletion endpoints with a multi-step confirmation process for safety.
    ///
    /// The deletion flow consists of three possible actions:
    /// 1. Initiating deletion (requires re-authentication)
    /// 2. Confirming the deletion
    /// 3. Canceling a pending deletion
    ///
    /// This multi-step process helps prevent accidental identity deletions. Example flow:
    /// ```swift
    /// // 1. Start deletion (requires recent authentication)
    /// let delete = Identity.Deletion.API.request(
    ///   .init(reauthToken: "recent-auth-token")
    /// )
    ///
    /// // 2. Identity can either confirm:
    /// let confirm = Identity.Deletion.API.confirm
    ///
    /// // Or cancel:
    /// let cancel = Identity.Deletion.API.cancel
    /// ```
    ///
    /// > Important: Identity deletion is permanent and cannot be undone after confirmation.
    /// > Identities have a grace period between request and confirmation during which they can cancel.
    @Prisms
    @Folds
    @Cases
    public enum API: Codable, Hashable, Sendable {
        /// Initiates identity deletion, requiring recent authentication
        case request(Identity.Deletion.Request)

        /// Cancels a pending identity deletion request
        case cancel

        /// Confirms and executes the identity deletion
        case confirm
    }
}

extension Identity.Deletion.API: HTTP.Routable {
    /// Routes identity deletion requests to their appropriate handlers.
    ///
    /// Defines the URL structure for the deletion flow:
    /// - Initial request: `POST /delete/request`
    /// - Cancellation: `POST /delete/cancel`
    /// - Confirmation: `POST /delete/confirm`
    ///
    /// The request endpoint expects re-authentication data, while cancel and confirm
    /// endpoints operate on the authenticated user's pending deletion request.
    public static var router: some HTTP.Router.`Protocol`<Identity.Deletion.API> {
        Coder::Case(
            Identity.Deletion.API.cases.request.prism,
            Identity.Deletion.API.cases.request.fold,
            absent: .mismatch
        ) {
            HTTP.Segment.request
            Identity.Deletion.Request.router
        }

        Coder::Case(
            Identity.Deletion.API.cases.cancel.prism,
            Identity.Deletion.API.cases.cancel.fold,
            absent: .mismatch
        ) {
            HTTP.Segment.cancel
            HTTP.Method.post
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.Deletion.API.cases.confirm.prism,
            Identity.Deletion.API.cases.confirm.fold,
            absent: .mismatch
        ) {
            HTTP.Segment.confirm
            HTTP.Method.post
            HTTP.Segment.End()
        }
    }
}
