//
//  Identity.View.OAuth.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2025.
//

import CasePaths
import Foundation
import ServerFoundation

extension Identity.View {
    /// OAuth view routes for UI pages
    @CasePathable
    @dynamicMemberLookup
    public enum OAuth: Equatable, Sendable {
        /// OAuth login page showing available providers
        case login
        
        /// OAuth callback handling page
        case callback(Identity.OAuth.CallbackRequest)
        
        /// OAuth connection management page
        case connections
        
        /// OAuth error page
        case error(String)
    }
}

extension Identity.View.OAuth {
    /// Router for OAuth view routes
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.View.OAuth> {
            OneOf {
                // GET /oauth/login
                URLRouting.Route(.case(Identity.View.OAuth.login)) {
                    Method.get
                    Path { "oauth" }
                    Path { "login" }
                }
                
                // GET /oauth/callback
                URLRouting.Route(.case(Identity.View.OAuth.callback)) {
                    Method.get
                    Path { "oauth" }
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
                URLRouting.Route(.case(Identity.View.OAuth.connections)) {
                    Method.get
                    Path { "oauth" }
                    Path { "connections" }
                }
                
                // GET /oauth/error
                URLRouting.Route(.case(Identity.View.OAuth.error)) {
                    Method.get
                    Path { "oauth" }
                    Path { "error" }
                    URLRouting.Query {
                        Field("message") { Parse(.string) }
                    }
                }
            }
        }
    }
}
