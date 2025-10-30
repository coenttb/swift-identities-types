//
//  Identity.Email.Route.swift
//  swift-identities
//
//  Feature-based routing for Email functionality
//

import CasePaths
import TypesFoundation

extension Identity.Email {
  /// View routes for email management pages.
  ///
  /// Provides frontend routes for email-related operations.
  @CasePathable
  @dynamicMemberLookup
  public enum View: Equatable, Sendable {
    /// Email change flow views
    case change(Change)

    /// Email change view endpoints
    @CasePathable
    @dynamicMemberLookup
    public enum Change: Equatable, Sendable {
      /// Email change request page
      case request

      /// Email change confirmation page with token
      case confirm(Identity.Email.Change.Confirmation)

      /// Reauthorization page for email change
      case reauthorization

      public static let confirm: Self = .confirm(.init())
    }
  }
}

extension Identity.Email.View {
  /// Router for email view endpoints.
  ///
  /// Maps view routes to their URL paths:
  /// - Change flow: `/email/change/...`
  public struct Router: ParserPrinter, Sendable {
    public init() {}

    public var body: some URLRouting.Router<Identity.Email.View> {
      URLRouting.Route(.case(Identity.Email.View.change)) {
        Path { "change" }
        Identity.Email.View.Change.Router()
      }
    }
  }
}

extension Identity.Email.View.Change {
  /// Router for email change view endpoints.
  ///
  /// Maps view routes to their URL paths:
  /// - Request: `/email/change/request`
  /// - Confirm: `/email/change/confirm`
  /// - Reauthorization: `/email/change/reauthorization`
  public struct Router: ParserPrinter, Sendable {
    public init() {}

    public var body: some URLRouting.Router<Identity.Email.View.Change> {
      OneOf {
        URLRouting.Route(.case(Identity.Email.View.Change.request)) {
          Path { "request" }
        }

        URLRouting.Route(.case(Identity.Email.View.Change.confirm)) {
          Path { "confirm" }
          Identity.Email.Change.Confirmation.Router()
        }

        URLRouting.Route(.case(Identity.Email.View.Change.reauthorization))
      }
    }
  }
}
