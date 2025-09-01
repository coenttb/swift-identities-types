//
//  Identity.Email.Route.swift
//  swift-identities
//
//  Feature-based routing for Email functionality
//

import CasePaths
import ServerFoundation

extension Identity.Email {
    /// Complete routing for email management features including both API and View endpoints.
    ///
    /// This combines email management functionality for:
    /// - API endpoints (backend operations)
    /// - View endpoints (frontend pages)
    ///
    /// Usage:
    /// ```swift
    /// let route = Identity.Email.Route.api(.change(.request(...)))
    /// let viewRoute = Identity.Email.Route.view(.change(.request))
    /// ```
    @CasePathable
    @dynamicMemberLookup
    public enum Route: Equatable, Sendable {
        /// API endpoints for email operations
        case api(API)
        
        /// View endpoints for email pages
        case view(View)
    }
}

extension Identity.Email {
    /// API endpoints for email management.
    ///
    /// Inherits from the existing Identity.API.Email structure
    /// to maintain backward compatibility while enabling feature-based organization.
    public typealias API = Identity.API.Email
}

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

extension Identity.Email.Route {
    /// Router for the complete Email feature including both API and View routes.
    ///
    /// URL structure:
    /// - API routes: `/api/email/...`
    /// - View routes: `/email/...`
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.Email.Route> {
            OneOf {
                // API routes under /api prefix
                URLRouting.Route(.case(Identity.Email.Route.api)) {
                    Path { "api" }
                    Path { "email" }
                    Identity.API.Email.Router()
                }
                
                // View routes (no /api prefix)
                URLRouting.Route(.case(Identity.Email.Route.view)) {
                    Path { "email" }
                    Identity.Email.View.Router()
                }
            }
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
                
                URLRouting.Route(.case(Identity.Email.View.Change.reauthorization)) {
                    Path { "reauthorization" }
                }
            }
        }
    }
}
