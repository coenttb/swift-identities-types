//
//  Identity.OAuth.API.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2025.
//

import CasePaths
import Foundation
import TypesFoundation

extension Identity.OAuth {
  /// OAuth-related API endpoints
  @CasePathable
  @dynamicMemberLookup
  public enum API: Equatable, Sendable {
    /// Get list of available OAuth providers
    case providers

    /// Initiate OAuth authorization flow
    case authorize(provider: String)

    /// Handle OAuth callback with code and state
    case callback(Identity.OAuth.CallbackRequest)

    /// Get current OAuth connections
    case connections

    /// Disconnect an OAuth provider
    case disconnect(provider: String)
  }
}

extension Identity.OAuth.API {
  /// Router for OAuth API endpoints
  public struct Router: ParserPrinter, Sendable {
    public init() {}

    public var body: some URLRouting.Router<Identity.OAuth.API> {
      OneOf {
        // GET /oauth/providers
        URLRouting.Route(.case(Identity.OAuth.API.providers)) {
          Method.get
          Path { "providers" }
        }

        // GET /oauth/authorize/:provider
        URLRouting.Route(.case(Identity.OAuth.API.authorize)) {
          Method.get
          Path { "authorize" }
          Path { Parse(.string) }  // provider
        }

        // GET /oauth/callback
        URLRouting.Route(.case(Identity.OAuth.API.callback)) {
          Method.get
          Path { "callback" }

          Parse(.memberwise(Identity.OAuth.CallbackRequest.init)) {
            URLRouting.Query {
              Field("provider", .string, default: "github")
              Field("code") { Parse(.string) }
              Field("state") { Parse(.string) }
              Optionally {
                Field("redirect_uri") { Parse(.string) }
              }
            }
          }
        }

        // GET /oauth/connections
        URLRouting.Route(.case(Identity.OAuth.API.connections)) {
          Method.get
          Path { "connections" }
        }

        // DELETE /oauth/disconnect/:provider
        URLRouting.Route(.case(Identity.OAuth.API.disconnect)) {
          Method.delete
          Path { "disconnect" }
          Path { Parse(.string) }  // provider
        }
      }
    }
  }
}
