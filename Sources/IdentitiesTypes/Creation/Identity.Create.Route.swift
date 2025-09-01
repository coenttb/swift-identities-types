//
//  Identity.Creation.Route.swift
//  swift-identities
//
//  Feature-based routing for Create functionality
//

import CasePaths
import ServerFoundation

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
        case api(API)
        
        /// View endpoints for creation pages
        case view(View)
    }
}

extension Identity.Creation {
    /// API endpoints for identity creation.
    ///
    /// Inherits from the existing Identity.API.Create structure
    /// to maintain backward compatibility while enabling feature-based organization.
    public typealias API = Identity.API.Create
}

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
