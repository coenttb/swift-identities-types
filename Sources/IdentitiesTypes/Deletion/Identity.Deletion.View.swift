//
//  Identity.Deletion.Route.swift
//  swift-identities
//
//  Feature-based routing for Delete functionality
//

import CasePaths
import TypesFoundation

extension Identity.Deletion {
  /// View routes for identity deletion pages.
  ///
  /// Provides frontend routes for the deletion flow.
  @CasePathable
  @dynamicMemberLookup
  public enum View: Equatable, Sendable {
    /// Identity deletion request page
    case request

    // Could add confirmation or status pages in the future:
    // case confirm
    // case pending
  }
}

extension Identity.Deletion.View {
  /// Router for deletion view endpoints.
  ///
  /// Maps view routes to their URL paths:
  /// - Request: `/delete` (main deletion page)
  public struct Router: ParserPrinter, Sendable {
    public init() {}

    public var body: some URLRouting.Router<Identity.Deletion.View> {
      URLRouting.Route(.case(Identity.Deletion.View.request))
    }
  }
}
