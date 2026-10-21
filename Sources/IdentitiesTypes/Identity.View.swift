//
//  Identity.View.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 07/10/2024.
//

import Case_Macro
import Coder
import HTTP
import HTTP_Router

extension Identity {
    /// View routing and navigation states for the identity consumer interface.
    ///
    /// This namespace defines the possible view states and navigation flows for client-side
    /// identity management, including:
    /// - Authentication (login/logout)
    /// - Account creation and verification
    /// - Profile management (email, password)
    /// - Account deletion
    @Prisms
    @Folds
    @Cases
    public enum View: Equatable, Sendable {
        case authenticate(Identity.Authentication.View)
        case create(Identity.Creation.View)
        case delete(Identity.Deletion.View)
        case logout
        case email(Identity.Email.View)
        case password(Identity.Password.View)
        case mfa(Identity.MFA.View)
        case oauth(Identity.View.OAuth)
    }
}

extension Identity.View {
    /// Convenience accessor for the login view state.
    public static let login: Self = .authenticate(.credentials)
}

// Note: The nested type definitions have been removed as we're now using
// the feature-based types directly (Identity.Authentication.View, Identity.Creation.View, etc.)
// These are defined in their respective feature modules.

extension Identity.View: HTTP.Routable {
    /// URL router for mapping between URLs and view states.
    ///
    /// This router handles bidirectional conversion between URLs and view states,
    /// defining the client-side routing structure for all identity management flows.
    public static var router: some HTTP.Router.`Protocol`<Identity.View> {

        Coder::Case(
            Identity.View.cases.create.prism,
            Identity.View.cases.create.fold,
            absent: .mismatch
        ) {
            HTTP.Segment.create
            // Delegate to the feature's view router
            Identity.Creation.View.router
        }

        Coder::Case(
            Identity.View.cases.logout.prism,
            Identity.View.cases.logout.fold,
            absent: .mismatch
        ) {
            HTTP.Method.post
            HTTP.Segment.logout
            HTTP.Segment("view")
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.View.cases.delete.prism,
            Identity.View.cases.delete.fold,
            absent: .mismatch
        ) {
            HTTP.Segment.delete
            Identity.Deletion.View.router
        }

        Coder::Case(
            Identity.View.cases.password.prism,
            Identity.View.cases.password.fold,
            absent: .mismatch
        ) {
            HTTP.Segment.password
            // Delegate to the feature's view router
            Identity.Password.View.router
        }

        Coder::Case(
            Identity.View.cases.email.prism,
            Identity.View.cases.email.fold,
            absent: .mismatch
        ) {
            HTTP.Segment.email
            // Delegate to the feature's view router
            Identity.Email.View.router
        }

        Coder::Case(Identity.View.cases.mfa.prism, Identity.View.cases.mfa.fold, absent: .mismatch) {
            HTTP.Segment("mfa")
            // Delegate to the feature's view router
            Identity.MFA.View.router
        }

        Coder::Case(
            Identity.View.cases.oauth.prism,
            Identity.View.cases.oauth.fold,
            absent: .mismatch
        ) {
            // Delegate to the feature's view router
            Identity.View.OAuth.router
        }

        Coder::Case(
            Identity.View.cases.authenticate.prism,
            Identity.View.cases.authenticate.fold,
            absent: .mismatch
        ) {
            // Delegate to the feature's view router
            Identity.Authentication.View.router
        }
    }
}
