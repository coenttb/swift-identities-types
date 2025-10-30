//
//  Identity.Password.API.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

import CasePaths
import TypesFoundation

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
  @CasePathable
  @dynamicMemberLookup
  public enum API: Equatable, Sendable {
    /// Password reset flow for forgotten passwords
    case reset(Identity.Password.Reset.API)

    /// Password change flow for authenticated users
    case change(Identity.Password.Change.API)
  }
}

extension Identity.Password.API {
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
    public var body: some URLRouting.Router<Identity.Password.API> {
      OneOf {
        URLRouting.Route(.case(Identity.Password.API.reset)) {
          Path { "reset" }

          OneOf {
            URLRouting.Route(.case(Identity.Password.Reset.API.request)) {
              Identity.Password.Reset.Request.Router()
            }

            URLRouting.Route(.case(Identity.Password.Reset.API.confirm)) {
              Identity.Password.Reset.Confirm.Router()
            }
          }
        }

        URLRouting.Route(.case(Identity.Password.API.change)) {
          Path { "change" }

          OneOf {
            URLRouting.Route(.case(Identity.Password.Change.API.request)) {
              Identity.Password.Change.Request.Router()
            }
          }
        }
      }
    }
  }
}
