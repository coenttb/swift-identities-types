//
//  Identity.Email.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 18/02/2025.
//

import Case_Macro
import Coder
import Foundation
import HTTP
import HTTP_Router

extension Identity.Email {
    /// Email management endpoints for handling email address updates.
    ///
    /// Currently supports email address changes through a secure verification process:
    /// 1. Request to change email (requires current auth)
    /// 2. Verify new email via confirmation token
    ///
    /// Future extensions may include additional email management features.
    @Prisms
    @Folds
    @Cases
    public enum API: Equatable, Sendable {
        /// Email address change operation
        case change(Identity.Email.Change.API)
    }
}

extension Identity.Email.API: HTTP.Routable {
    /// Routes email management requests to their appropriate handlers.
    ///
    /// Currently routes email change requests to the email change flow handler.
    /// Structure is extensible for future email management features.
    public static var router: some HTTP.Router.`Protocol`<Identity.Email.API> {
        Coder::Case(
            Identity.Email.API.cases.change.prism,
            Identity.Email.API.cases.change.fold,
            absent: .mismatch
        ) {
            Identity.Email.Change.API.router
        }
    }
}

extension Identity.Email.Change {
    /// Email change endpoints implementing a secure two-step verification process.
    ///
    /// The email change flow consists of:
    /// 1. Requesting the change with the new email address
    /// 2. Confirming via a token sent to the new address
    ///
    /// Example of the email change flow:
    /// ```swift
    /// // 1. Request email change
    /// let change = Identity.Email.Change.API.request(
    ///   .init(newEmail: "new@example.com")
    /// )
    ///
    /// // 2. Confirm with token from email
    /// let confirm = Identity.Email.Change.API.confirm(
    ///   .init(token: "verification-token")
    /// )
    /// ```
    ///
    /// > Important: The new email address is not activated until confirmed
    /// > through the verification token sent to that address.
    @Prisms
    @Folds
    @Cases
    public enum API: Equatable, Sendable {
        /// Initiates an email change request with the new address
        case request(Identity.Email.Change.Request)

        /// Confirms the email change using a verification token
        case confirm(Identity.Email.Change.Confirmation)
    }
}

extension Identity.Email.Change.API: HTTP.Routable {
    /// Routes email change requests to their appropriate handlers.
    ///
    /// Defines the URL structure for the email change flow:
    /// - Initial request: `POST /email/change/request`
    /// - Confirmation: `POST /email/change/confirm`
    ///
    /// Both endpoints expect form-encoded request bodies containing the
    /// necessary change request or confirmation data.
    public static var router: some HTTP.Router.`Protocol`<Identity.Email.Change.API> {
        Coder::Case(
            Identity.Email.Change.API.cases.request.prism,
            Identity.Email.Change.API.cases.request.fold,
            absent: .mismatch
        ) {
            Identity.Email.Change.Request.router
        }

        Coder::Case(
            Identity.Email.Change.API.cases.confirm.prism,
            Identity.Email.Change.API.cases.confirm.fold,
            absent: .mismatch
        ) {
            Identity.Email.Change.Confirmation.router
        }
    }
}
