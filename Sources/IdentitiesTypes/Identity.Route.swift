//
//  Identity.Route.swift
//  swift-identities
//
//  Feature-based routing system for identity management
//

import CasePaths
import TypesFoundation

extension Identity {
    /// Complete routing system organized by features.
    ///
    /// This feature-based routing structure groups related functionality together.
    /// Each feature contains its own API, View, and Route definitions.
    ///
    /// Features included:
    /// - Create: Identity creation and verification
    /// - Authenticate: Login and authentication
    /// - Delete: Identity deletion
    /// - Email: Email management
    /// - Password: Password reset and change
    /// - MFA: Multi-factor authentication
    /// - Logout: Sign out functionality
    /// - Reauthorize: Sensitive operation verification
    ///
    /// Usage:
    /// ```swift
    /// let route = Identity.Route.create(.api(.request(...)))
    /// let viewRoute = Identity.Route.password(.view(.reset(.request)))
    /// ```
    @CasePathable
    @dynamicMemberLookup
    public enum Route: Equatable, Sendable {
        /// Identity creation and verification
        case create(Creation.Route)
        
        /// Authentication and login
        case authenticate(Authentication.Route)
        
        /// Identity deletion
        case delete(Deletion.Route)
        
        /// Email management
        case email(Email.Route)
        
        /// Password management
        case password(Password.Route)
        
        /// Multi-factor authentication
        case mfa(MFA.Route)
        
        /// Logout endpoint
        case logout(Logout.Route)
        
        /// Reauthorization for sensitive operations
        case reauthorize(Reauthorization.Route)
        
        /// OAuth provider authentication
        case oauth(OAuth.Route)
    }
}

extension Identity.Route {
    /// Router for the complete composed identity system.
    ///
    /// This router combines all feature routers into a unified routing system.
    /// Each feature maintains its own URL namespace.
    ///
    /// URL structure:
    /// - `/create/...` - Creation routes
    /// - `/login` - Authentication routes
    /// - `/delete/...` - Deletion routes
    /// - `/email/...` - Email management routes
    /// - `/password/...` - Password management routes
    /// - `/mfa/...` - MFA routes
    /// - `/logout` - Logout endpoint
    /// - `/reauthorize` - Reauthorization endpoint
    public struct Router: ParserPrinter, Sendable {
        public init() {}

        public var body: some URLRouting.Router<Identity.Route> {
            OneOf {
                // Create feature routes
                URLRouting.Route(.case(Identity.Route.create)) {
                    Identity.Creation.Route.Router()
                }

                // Authenticate feature routes
                URLRouting.Route(.case(Identity.Route.authenticate)) {
                    Identity.Authentication.Route.Router()
                }

                // Delete feature routes
                URLRouting.Route(.case(Identity.Route.delete)) {
                    Identity.Deletion.Route.Router()
                }

//                 Email feature routes
                URLRouting.Route(.case(Identity.Route.email)) {
                    Identity.Email.Route.Router()
                }
//
                // Password feature routes
                URLRouting.Route(.case(Identity.Route.password)) {
                    Identity.Password.Route.Router()
                }

                // MFA feature routes (optional)
                URLRouting.Route(.case(Identity.Route.mfa)) {
                    Identity.MFA.Route.Router()
                }

                // Logout endpoint
                URLRouting.Route(.case(Identity.Route.logout)) {
                    Identity.Logout.Route.Router()
                }

                // Reauthorization endpoint
                URLRouting.Route(.case(Identity.Route.reauthorize)) {
                    Identity.Reauthorization.Route.Router()
                }

                // OAuth feature routes (optional)
                URLRouting.Route(.case(Identity.Route.oauth)) {
                    Identity.OAuth.Route.Router()
                }
            }
        }
    }
}

// MARK: - Convenience Extensions for Common Routes

extension Identity.Route {
    /// Quick access to login page
    public static var login: Self {
        .authenticate(.view(.credentials))
    }
    
    /// Quick access to signup page
    public static var signup: Self {
        .create(.view(.request))
    }
    
    /// Quick access to password reset
    public static var passwordReset: Self {
        .password(.view(.reset(.request)))
    }
}

// MARK: - Backward Compatibility

extension Identity.Route {
    /// Maps old API-based routing to new feature-based routing.
    ///
    /// This provides backward compatibility for code using the old `.api()` pattern.
    /// 
    /// Example:
    /// ```swift
    /// // Old: router.url(for: .api(.create(.request(...))))
    /// // New: router.url(for: .create(.api(.request(...))))
    /// ```
    public static func api(_ api: Identity.API) -> Identity.Route {
        switch api {
        case .authenticate(let auth):
            return .authenticate(.api(auth))
        case .create(let create):
            return .create(.api(create))
        case .delete(let delete):
            return .delete(.api(delete))
        case .email(let email):
            return .email(.api(email))
        case .password(let password):
            return .password(.api(password))
        case .mfa(let mfa):
            return .mfa(.api(mfa))
        case .logout(let logout):
            return .logout(.api(logout))
        case .reauthorize(let reauth):
            return .reauthorize(.api(reauth))
        case .oauth(let oauth):
            return .oauth(.api(oauth))
        }
    }
    
    /// Maps old View-based routing to new feature-based routing.
    ///
    /// This provides backward compatibility for code using the old `.view()` pattern.
    /// Since Identity.View now directly uses the new feature-based types,
    /// this is a simpler direct mapping.
    /// 
    /// Example:
    /// ```swift
    /// // Old: router.url(for: .view(.create(.verify)))
    /// // New: router.url(for: .create(.view(.verify)))
    /// ```
    public static func view(_ view: Identity.View) -> Identity.Route {
        switch view {
        case .authenticate(let auth):
            return .authenticate(.view(auth))
        case .create(let create):
            return .create(.view(create))
        case .delete:
            return .delete(.view(.request))
        case .logout:
            return .login
        case .email(let email):
            return .email(.view(email))
        case .password(let password):
            return .password(.view(password))
        case .mfa(let mfa):
            return .mfa(.view(mfa))
        case .oauth(let oath):
            return .oauth(.view(oath))
        }
    }
}
