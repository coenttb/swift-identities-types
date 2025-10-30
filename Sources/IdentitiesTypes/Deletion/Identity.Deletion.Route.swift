//
//  Identity.Deletion.Route.swift
//  swift-identities
//
//  Feature-based routing for Delete functionality
//

import CasePaths
import TypesFoundation

extension Identity.Deletion {
  /// Complete routing for identity deletion features including both API and View endpoints.
  ///
  /// This combines identity deletion functionality for:
  /// - API endpoints (backend operations)
  /// - View endpoints (frontend pages)
  ///
  /// Usage:
  /// ```swift
  /// let route = Identity.Deletion.Route.api(.request(...))
  /// let viewRoute = Identity.Deletion.Route.view(.request)
  /// ```
  @CasePathable
  @dynamicMemberLookup
  public enum Route: Equatable, Sendable {
    /// API endpoints for deletion operations
    case api(API)

    /// View endpoints for deletion pages
    case view(View)
  }
}

extension Identity.Deletion.Route {
  /// Router for the complete Delete feature including both API and View routes.
  ///
  /// URL structure:
  /// - API routes: `/api/delete/...`
  /// - View routes: `/delete`
  public struct Router: ParserPrinter, Sendable {
    public init() {}

    public var body: some URLRouting.Router<Identity.Deletion.Route> {
      OneOf {
        // API routes under /api prefix
        URLRouting.Route(.case(Identity.Deletion.Route.api)) {
          Path { "api" }
          Path { "delete" }
          Identity.Deletion.API.Router()
        }

        // View routes (no /api prefix)
        URLRouting.Route(.case(Identity.Deletion.Route.view)) {
          Path { "delete" }
          Identity.Deletion.View.Router()
        }
      }
    }
  }
}
