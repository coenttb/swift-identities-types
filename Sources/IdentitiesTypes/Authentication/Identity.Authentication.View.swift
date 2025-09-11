//
//  Identity.Authentication.Route.swift
//  swift-identities
//
//  Feature-based routing for Authentication functionality
//

import CasePaths
import TypesFoundation

extension Identity.Authentication {
    /// View routes for authentication pages.
    ///
    /// Provides frontend routes for different authentication methods.
    @CasePathable
    @dynamicMemberLookup
    public enum View: Sendable, Hashable, Codable  {
        /// Credentials-based login page (username/password)
        case credentials
        
        // Future authentication methods can be added here:
        // case oauth(provider: OAuthProvider)
        // case sso
        // case passwordless
    }
}

extension Identity.Authentication.View {
    /// Router for authentication view endpoints.
    ///
    /// Maps view routes to their URL paths:
    /// - Credentials: `/login` or `/credentials` (both map to same page)
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.Authentication.View> {
            // Support both /login and /credentials paths
            OneOf {
                URLRouting.Route(.case(Identity.Authentication.View.credentials)) {
                    Path { "login" }
                }
                
                URLRouting.Route(.case(Identity.Authentication.View.credentials)) {
                    Path { "credentials" }
                }
            }
            
            // Future auth methods would be added here:
            // URLRouting.Route(.case(Identity.Authentication.View.oauth)) {
            //     Path { "oauth" }
            //     OAuthProvider.Router()
            // }
        }
    }
}
