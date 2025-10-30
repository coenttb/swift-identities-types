//
//  Identity.Email.Route.swift
//  swift-identities
//
//  Feature-based routing for Email functionality
//

import CasePaths
import TypesFoundation

extension Identity.Email {
  /// Complete routing for email management features including both API and View endpoints.
  ///
  /// This combines email management functionality for:
  /// - API endpoints (backend operations)
  /// - View endpoints (frontend pages)
  ///
  /// Usage:
  /// ```swift
  /// let route = Identity.Email.Route.api(.change(.request(...)))
  /// let viewRoute = Identity.Email.Route.view(.change(.request))
  /// ```
  @CasePathable
  @dynamicMemberLookup
  public enum Route: Equatable, Sendable {
    /// API endpoints for email operations
    case api(API)

    /// View endpoints for email pages
    case view(View)
  }
}

extension Identity.Email.Route {
  /// Router for the complete Email feature including both API and View routes.
  ///
  /// URL structure:
  /// - API routes: `/api/email/...`
  /// - View routes: `/email/...`
  public struct Router: ParserPrinter, Sendable {
    public init() {}

    public var body: some URLRouting.Router<Identity.Email.Route> {
      OneOf {
        // API routes under /api prefix
        URLRouting.Route(.case(Identity.Email.Route.api)) {
          Path { "api" }
          Path { "email" }
          Identity.Email.API.Router()
        }

        // View routes (no /api prefix)
        URLRouting.Route(.case(Identity.Email.Route.view)) {
          Path { "email" }
          Identity.Email.View.Router()
        }
      }
    }
  }
}
