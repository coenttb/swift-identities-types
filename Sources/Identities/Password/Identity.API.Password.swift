//
//  Identity.API.Password.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

import CasePaths
import Swift_Web

extension Identity.API {
    /// Password management endpoints for handling password changes and resets.
    ///
    /// Supports two primary password operations:
    /// 1. Password reset (forgotten password flow)
    /// 2. Password change (authenticated user changing their password)
    ///
    /// Example of initiating a password reset:
    /// ```swift
    /// // Request password reset
    /// let reset = Identity.API.Password.reset(
    ///   .request(.init(email: "user@example.com"))
    /// )
    ///
    /// // Change password while authenticated
    /// let change = Identity.API.Password.change(
    ///   .request(.init(
    ///     currentPassword: "old-password",
    ///     newPassword: "new-password"
    ///   ))
    /// )
    /// ```
    @CasePathable
    @dynamicMemberLookup
    public enum Password: Equatable, Sendable {
        /// Password reset flow for forgotten passwords
        case reset(Identity.API.Password.Reset)

        /// Password change flow for authenticated users
        case change(Identity.API.Password.Change)
    }
}

extension Identity.API.Password {
    /// Password reset endpoints implementing a secure two-step verification process.
    ///
    /// The reset flow consists of:
    /// 1. Requesting a reset using the identity's email
    /// 2. Setting a new password using a verification token
    ///
    /// > Important: Reset tokens expire after a short time period and
    /// > can only be used once.
    @CasePathable
    @dynamicMemberLookup
    public enum Reset: Equatable, Sendable {
        /// Initiates a password reset request
        case request(Identity.Password.Reset.Request)

        /// Confirms the reset with a token and new password
        case confirm(Identity.Password.Reset.Confirm)
    }
}

extension Identity.API.Password {
    /// Password change endpoint for authenticated users.
    ///
    /// Requires the user's current password for security verification
    /// before allowing the password change.
    @CasePathable
    @dynamicMemberLookup
    public enum Change: Equatable, Sendable {
        /// Request to change password with current and new passwords
        case request(change: Identity.Password.Change.Request)
    }
}

extension Identity.API.Password {
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
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        /// The routing logic for password management endpoints.
        ///
        /// Composes routes for both password reset and change flows:
        /// - Reset flow (request and confirm steps)
        /// - Change flow (authenticated change)
        ///
        /// Each route enforces proper authentication and security
        /// requirements for password operations.
        public var body: some URLRouting.Router<Identity.API.Password> {
            OneOf {
                URLRouting.Route(.case(Identity.API.Password.reset)) {
                    Path.reset

                    OneOf {
                        URLRouting.Route(.case(Identity.API.Password.Reset.request)) {
                            Identity.Password.Reset.Request.Router()
                        }

                        URLRouting.Route(.case(Identity.API.Password.Reset.confirm)) {
                            Identity.Password.Reset.Confirm.Router()
                        }
                    }
                }

                URLRouting.Route(.case(Identity.API.Password.change)) {
                    Path.change

                    OneOf {
                        URLRouting.Route(.case(Identity.API.Password.Change.request)) {
                            Identity.Password.Change.Request.Router()
                        }
                    }
                }
            }
        }
    }
}
