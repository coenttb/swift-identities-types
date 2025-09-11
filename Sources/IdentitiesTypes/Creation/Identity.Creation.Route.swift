//
//  Identity.Creation.Route.swift
//  swift-identities
//
//  Feature-based routing for Create functionality
//

import CasePaths
import TypesFoundation

extension Identity.Creation {
    /// Complete routing for identity creation features including both API and View endpoints.
    ///
    /// This combines identity creation functionality for:
    /// - API endpoints (backend operations)
    /// - View endpoints (frontend pages)
    ///
    /// Usage:
    /// ```swift
    /// let route = Identity.Creation.Route.api(.request(...))
    /// let viewRoute = Identity.Creation.Route.view(.request)
    /// ```
    @CasePathable
    @dynamicMemberLookup
    public enum Route: Equatable, Sendable {
        /// API endpoints for creation operations
        case api(Identity.Creation.API)
        
        /// View endpoints for creation pages
        case view(Identity.Creation.View)
    }
}

extension Identity.Creation.Route {
    /// Router for the complete Create feature including both API and View routes.
    ///
    /// URL structure:
    /// - API routes: `/api/create/...`
    /// - View routes: `/create/...`
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.Creation.Route> {
            OneOf {
                // API routes under /api prefix
                URLRouting.Route(.case(Identity.Creation.Route.api)) {
                    Path { "api" }
                    Path { "create" }
                    Identity.Creation.API.Router()
                }
                
                // View routes (no /api prefix)
                URLRouting.Route(.case(Identity.Creation.Route.view)) {
                    Path { "create" }
                    Identity.Creation.View.Router()
                }
            }
        }
    }
}
