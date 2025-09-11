//
//  Identity.OAuth.Route.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2025.
//

import CasePaths
import Foundation
import TypesFoundation

extension Identity.OAuth {
    /// OAuth-specific routes
    @CasePathable
    @dynamicMemberLookup
    public enum Route: Equatable, Sendable {
        case api(Identity.OAuth.API)
        case view(Identity.View.OAuth)
    }
}

extension Identity.OAuth.Route {
    /// Router for OAuth routes
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.OAuth.Route> {
            OneOf {
                // API routes
                URLRouting.Route(.case(Identity.OAuth.Route.api)) {
                    Path { "api" }
                    Path { "oauth" }
                    Identity.OAuth.API.Router()
                }
                
                // View routes
                URLRouting.Route(.case(Identity.OAuth.Route.view)) {
                    Identity.View.OAuth.Router()
                }
            }
        }
    }
}
