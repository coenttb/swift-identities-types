//
//  Identity.API.OAuth.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2025.
//

import CasePaths
import Foundation
import ServerFoundation

extension Identity.API {
    /// OAuth-related API endpoints
    @CasePathable
    @dynamicMemberLookup
    public enum OAuth: Equatable, Sendable {
        /// Get list of available OAuth providers
        case providers
        
        /// Initiate OAuth authorization flow
        case authorize(provider: String)
        
        /// Handle OAuth callback with code and state
        case callback(Identity.OAuth.Credentials)
        
        /// Get current OAuth connections
        case connections
        
        /// Disconnect an OAuth provider
        case disconnect(provider: String)
    }
}

extension Identity.API.OAuth {
    /// Router for OAuth API endpoints
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.API.OAuth> {
            OneOf {
                // GET /oauth/providers
                URLRouting.Route(.case(Identity.API.OAuth.providers)) {
                    Method.get
                    Path { "oauth" }
                    Path { "providers" }
                }
                
                // GET /oauth/authorize/:provider
                URLRouting.Route(.case(Identity.API.OAuth.authorize)) {
                    Method.get
                    Path { "oauth" }
                    Path { "authorize" }
                    Path { Parse(.string) } // provider
                }
                
                // GET /oauth/callback
                URLRouting.Route(.case(Identity.API.OAuth.callback)) {
                    Method.get
                    Path { "oauth" }
                    Path { "callback" }
                    
                    Parse(.memberwise(Identity.OAuth.Credentials.init)) {
                        URLRouting.Query {
                            Field("code") { Parse(.string) }
                            Field("state") { Parse(.string) }
                            Field("provider", .string, default: "github")
                            Field("redirect_uri") { Parse(.string) }
                        }
                    }
                }
                
                // GET /oauth/connections
                URLRouting.Route(.case(Identity.API.OAuth.connections)) {
                    Method.get
                    Path { "oauth" }
                    Path { "connections" }
                }
                
                // DELETE /oauth/disconnect/:provider
                URLRouting.Route(.case(Identity.API.OAuth.disconnect)) {
                    Method.delete
                    Path { "oauth" }
                    Path { "disconnect" }
                    Path { Parse(.string) } // provider
                }
            }
        }
    }
}
