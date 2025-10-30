//
//  Identity.Creation.Route.swift
//  swift-identities
//
//  Feature-based routing for Create functionality
//

import CasePaths
import TypesFoundation

extension Identity.Creation {
  /// View routes for identity creation pages.
  ///
  /// Provides frontend routes for:
  /// - Creation request form
  /// - Email verification page
  @CasePathable
  @dynamicMemberLookup
  public enum View: Equatable, Sendable {
    /// Identity creation request page
    case request

    /// Email verification page with token and email
    case verify(Identity.Creation.Verification)

    public static let verify: Self = .verify(.init())
  }
}

extension Identity.Creation.View {
  /// Router for creation view endpoints.
  ///
  /// Maps view routes to their URL paths:
  /// - Request: `/create/request`
  /// - Verify: `/create/verify`
  public struct Router: ParserPrinter, Sendable {
    public init() {}

    public var body: some URLRouting.Router<Identity.Creation.View> {
      OneOf {
        URLRouting.Route(.case(Identity.Creation.View.request)) {
          Path { "request" }
        }

        URLRouting.Route(.case(Identity.Creation.View.verify)) {
          Path { "verify" }

          Parse(.memberwise(Identity.Creation.Verification.self.init)) {
            URLRouting.Query {
              Field(Identity.Creation.Verification.CodingKeys.token.rawValue, .string, default: "")
              Field(Identity.Creation.Verification.CodingKeys.email.rawValue, .string, default: "")
            }
          }
        }
      }
    }
  }
}
