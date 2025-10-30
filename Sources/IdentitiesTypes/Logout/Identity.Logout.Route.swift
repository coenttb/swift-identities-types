//
//  Identity.Logout.Route.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 22/08/2025.
//

import CasePaths
import TypesFoundation

extension Identity.Logout {
    /// Routes for logout functionality.
    ///
    /// Logout is a simple operation with just a single endpoint.
    /// It's typically accessed as a GET request that clears authentication.
    @CasePathable
    @dynamicMemberLookup
    public enum Route: Equatable, Sendable {
        case api(Identity.Logout.API)
        case view
    }
}

extension Identity.Logout.Route {
    /// Router for logout routes.
    ///
    /// Since logout is a simple endpoint with no sub-routes,
    /// this router doesn't need to match anything additional.
    public struct Router: ParserPrinter, Sendable {
        public init() {}

        public var body: some URLRouting.Router<Identity.Logout.Route> {
            OneOf {
                URLRouting.Route(.case(Identity.Logout.Route.api)) {
                    Path.logout
                    Identity.Logout.API.Router()
                }

                URLRouting.Route(.case(Identity.Logout.Route.view)) {
                    Path.logout
                }
            }
        }
    }
}

