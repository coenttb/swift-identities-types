//
//  Identity.API.Email.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 18/02/2025.
//

import CasePaths
import Foundation
import SwiftWeb

extension Identity.API {
    /// Email management endpoints for handling email address updates.
    ///
    /// Currently supports email address changes through a secure verification process:
    /// 1. Request to change email (requires current auth)
    /// 2. Verify new email via confirmation token
    ///
    /// Future extensions may include additional email management features.
    @CasePathable
    @dynamicMemberLookup
    public enum Email: Equatable, Sendable {
        /// Email address change operation
        case change(Identity.API.Email.Change)
    }
}

extension Identity.API.Email {
    /// Routes email management requests to their appropriate handlers.
    ///
    /// Currently routes email change requests to the email change flow handler.
    /// Structure is extensible for future email management features.
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.API.Email> {
            OneOf {
                URLRouting.Route(.case(Identity.API.Email.change)) {
                    Identity.API.Email.Change.Router()
                }
            }
        }
    }
}

extension Identity.API.Email {
    /// Email change endpoints implementing a secure two-step verification process.
    ///
    /// The email change flow consists of:
    /// 1. Requesting the change with the new email address
    /// 2. Confirming via a token sent to the new address
    ///
    /// Example of the email change flow:
    /// ```swift
    /// // 1. Request email change
    /// let change = Identity.API.Email.Change.request(
    ///   .init(newEmail: "new@example.com")
    /// )
    ///
    /// // 2. Confirm with token from email
    /// let confirm = Identity.API.Email.Change.confirm(
    ///   .init(token: "verification-token")
    /// )
    /// ```
    ///
    /// > Important: The new email address is not activated until confirmed
    /// > through the verification token sent to that address.
    @CasePathable
    @dynamicMemberLookup
    public enum Change: Equatable, Sendable {
        /// Initiates an email change request with the new address
        case request(Identity.Email.Change.Request)

        /// Confirms the email change using a verification token
        case confirm(Identity.Email.Change.Confirmation)
    }
}

extension Identity.API.Email.Change {
    /// Routes email change requests to their appropriate handlers.
    ///
    /// Defines the URL structure for the email change flow:
    /// - Initial request: `POST /email/change/request`
    /// - Confirmation: `POST /email/change/confirm`
    ///
    /// Both endpoints expect form-encoded request bodies containing the
    /// necessary change request or confirmation data.
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        /// The routing logic for email change endpoints.
        ///
        /// Composes routes for both steps of the email change process:
        /// - The initial change request
        /// - The confirmation step
        ///
        /// Each route uses its respective router to handle the specific
        /// request format and validation rules.
        public var body: some URLRouting.Router<Identity.API.Email.Change> {
            OneOf {
                URLRouting.Route(.case(Identity.API.Email.Change.request)) {
                    Identity.Email.Change.Request.Router()
                }

                URLRouting.Route(.case(Identity.API.Email.Change.confirm)) {
                    Identity.Email.Change.Confirmation.Router()
                }
            }
        }
    }
}
