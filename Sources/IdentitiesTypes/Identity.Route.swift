//
//  Identity.Route.swift
//  swift-identities
//
//  Feature-based routing system for identity management
//

import Case_Macro
import Coder
import HTTP
import HTTP_Router

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
    @Prisms
    @Folds
    @Cases
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

extension Identity.Route: HTTP.Routable {
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
    public static var router: some HTTP.Router.`Protocol`<Identity.Route> {
        // Create feature routes
        Coder::Case(
            Identity.Route.cases.create.prism,
            Identity.Route.cases.create.fold,
            absent: .mismatch
        ) {
            Identity.Creation.Route.router
        }

        // Authenticate feature routes
        Coder::Case(
            Identity.Route.cases.authenticate.prism,
            Identity.Route.cases.authenticate.fold,
            absent: .mismatch
        ) {
            Identity.Authentication.Route.router
        }

        // Delete feature routes
        Coder::Case(
            Identity.Route.cases.delete.prism,
            Identity.Route.cases.delete.fold,
            absent: .mismatch
        ) {
            Identity.Deletion.Route.router
        }

        //                 Email feature routes
        Coder::Case(
            Identity.Route.cases.email.prism,
            Identity.Route.cases.email.fold,
            absent: .mismatch
        ) {
            Identity.Email.Route.router
        }
        //
        // Password feature routes
        Coder::Case(
            Identity.Route.cases.password.prism,
            Identity.Route.cases.password.fold,
            absent: .mismatch
        ) {
            Identity.Password.Route.router
        }

        // MFA feature routes (optional)
        Coder::Case(
            Identity.Route.cases.mfa.prism,
            Identity.Route.cases.mfa.fold,
            absent: .mismatch
        ) {
            Identity.MFA.Route.router
        }

        // Logout endpoint
        Coder::Case(
            Identity.Route.cases.logout.prism,
            Identity.Route.cases.logout.fold,
            absent: .mismatch
        ) {
            Identity.Logout.Route.router
        }

        // Reauthorization endpoint
        Coder::Case(
            Identity.Route.cases.reauthorize.prism,
            Identity.Route.cases.reauthorize.fold,
            absent: .mismatch
        ) {
            Identity.Reauthorization.Route.router
        }

        // OAuth feature routes (optional)
        Coder::Case(
            Identity.Route.cases.oauth.prism,
            Identity.Route.cases.oauth.fold,
            absent: .mismatch
        ) {
            Identity.OAuth.Route.router
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
