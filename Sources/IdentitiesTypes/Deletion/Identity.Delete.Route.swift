//
//  Identity.Deletion.Route.swift
//  swift-identities
//
//  Feature-based routing for Delete functionality
//

import CasePaths
import ServerFoundation

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

extension Identity.Deletion {
    /// API endpoints for identity deletion.
    ///
    /// Inherits from the existing Identity.API.Delete structure
    /// to maintain backward compatibility while enabling feature-based organization.
    public typealias API = Identity.API.Delete
}

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
