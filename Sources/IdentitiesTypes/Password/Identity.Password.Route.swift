//
//  Identity.Password.Route.swift
//  swift-identities
//
//  Feature-based routing for Password functionality
//

import CasePaths
import ServerFoundation

extension Identity.Password {
    /// Complete routing for password-related features including both API and View endpoints.
    ///
    /// This combines password management functionality for:
    /// - API endpoints (backend operations)
    /// - View endpoints (frontend pages)
    ///
    /// Usage:
    /// ```swift
    /// let route = Identity.Password.Route.api(.reset(.request(...)))
    /// let viewRoute = Identity.Password.Route.view(.reset(.request))
    /// ```
    @CasePathable
    @dynamicMemberLookup
    public enum Route: Equatable, Sendable {
        /// API endpoints for password operations
        case api(API)
        
        /// View endpoints for password pages
        case view(View)
    }
}

extension Identity.Password {
    /// API endpoints for password management.
    ///
    /// Inherits from the existing Identity.API.Password structure
    /// to maintain backward compatibility while enabling feature-based organization.
    public typealias API = Identity.API.Password
}

extension Identity.Password {
    /// View routes for password-related pages.
    ///
    /// Provides frontend routes for:
    /// - Password reset flow (request and confirmation)
    /// - Password change flow for authenticated users
    @CasePathable
    @dynamicMemberLookup
    public enum View: Equatable, Sendable {
        /// Password reset view flow
        case reset(Reset)
        
        /// Password change view flow
        case change(Change)
        
        /// Password reset view endpoints
        @CasePathable
        @dynamicMemberLookup
        public enum Reset: Equatable, Sendable {
            /// Password reset request page
            case request
            
            /// Password reset confirmation page with token and new password
            case confirm(Identity.Password.Reset.Confirm)
            
            public static let confirm: Self = .confirm(.init())
        }
        
        /// Password change view endpoints
        @CasePathable
        @dynamicMemberLookup
        public enum Change: Equatable, Sendable {
            /// Password change request page
            case request
        }
    }
}

extension Identity.Password.Route {
    /// Router for the complete Password feature including both API and View routes.
    ///
    /// URL structure:
    /// - API routes: `/api/password/...`
    /// - View routes: `/password/...`
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.Password.Route> {
            OneOf {
                // API routes under /api prefix
                URLRouting.Route(.case(Identity.Password.Route.api)) {
                    Path { "api" }
                    Path { "password" }
                    Identity.API.Password.Router()
                }
                
                // View routes (no /api prefix)
                URLRouting.Route(.case(Identity.Password.Route.view)) {
                    Path { "password" }
                    Identity.Password.View.Router()
                }
            }
        }
    }
}

extension Identity.Password.View {
    /// Router for password view endpoints.
    ///
    /// Maps view routes to their URL paths:
    /// - Reset request: `/password/reset/request`
    /// - Reset confirm: `/password/reset/confirm`
    /// - Change request: `/password/change/request`
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.Password.View> {
            OneOf {
                URLRouting.Route(.case(Identity.Password.View.reset)) {
                    Path { "reset" }
                    Identity.Password.View.Reset.Router()
                }
                
                URLRouting.Route(.case(Identity.Password.View.change)) {
                    Path { "change" }
                    Identity.Password.View.Change.Router()
                }
            }
        }
    }
}

extension Identity.Password.View.Reset {
    /// Router for password reset view endpoints.
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.Password.View.Reset> {
            OneOf {
                URLRouting.Route(.case(Identity.Password.View.Reset.request)) {
                    Path { "request" }
                }
                
                URLRouting.Route(.case(Identity.Password.View.Reset.confirm)) {
                    Path { "confirm" }
                    Identity.Password.Reset.Confirm.Router()
                }
            }
        }
    }
}

extension Identity.Password.View.Change {
    /// Router for password change view endpoints.
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.Password.View.Change> {
            URLRouting.Route(.case(Identity.Password.View.Change.request)) {
                Path { "request" }
            }
        }
    }
}
