//
//  Identity.MFA.Route.swift
//  swift-identities
//
//  Feature-based routing for MFA functionality
//

import Case_Macro
import Coder
import HTTP
import HTTP_Router
import Pair

extension Identity.MFA {
    /// Complete routing for MFA features including both API and View endpoints.
    ///
    /// This combines MFA functionality for:
    /// - API endpoints (backend operations)
    /// - View endpoints (frontend pages)
    ///
    /// Usage:
    /// ```swift
    /// let route = Identity.MFA.Route.api(.totp(.setup(...)))
    /// let viewRoute = Identity.MFA.Route.view(.verify(...))
    /// ```
    @Prisms
    @Folds
    @Cases
    public enum Route: Equatable, Sendable {
        /// API endpoints for MFA operations
        case api(API)

        /// View endpoints for MFA pages
        case view(View)
    }
}

extension Identity.MFA {
    /// View routes for MFA pages.
    ///
    /// Provides frontend routes for MFA-related operations.
    @Prisms
    @Folds
    @Cases
    public enum View: Equatable, Sendable {
        /// MFA verification during login
        case verify(Identity.MFA.URLChallenge)

        /// MFA management page
        case manage

        /// TOTP-specific views
        case totp(TOTP)

        /// Backup codes views
        case backupCodes(BackupCodes)

        /// TOTP view endpoints
        @Prisms
        @Folds
        @Cases
        public enum TOTP: Equatable, Sendable {
            /// TOTP setup page
            case setup

            /// TOTP setup confirmation page
            case confirmSetup

            /// TOTP management page
            case manage
        }

        /// Backup codes view endpoints
        @Prisms
        @Folds
        @Cases
        public enum BackupCodes: Equatable, Sendable {
            /// Display newly generated backup codes
            case display

            /// Verify using backup code during login
            case verify(Identity.MFA.URLChallenge)
        }
    }
}

extension Identity.MFA.Route: HTTP.Routable {
    /// Router for the complete MFA feature including both API and View routes.
    ///
    /// URL structure:
    /// - API routes: `/api/mfa/...`
    /// - View routes: `/mfa/...`
    public static var router: some HTTP.Router.`Protocol`<Identity.MFA.Route> {
        // API routes under /api prefix
        Coder::Case(
            Identity.MFA.Route.cases.api.prism,
            Identity.MFA.Route.cases.api.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("api")
            HTTP.Segment("mfa")
            Identity.MFA.API.router
        }

        // View routes (no /api prefix)
        Coder::Case(
            Identity.MFA.Route.cases.view.prism,
            Identity.MFA.Route.cases.view.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("mfa")
            Identity.MFA.View.router
        }
    }
}

extension Identity.MFA.View: HTTP.Routable {
    /// Router for MFA view endpoints.
    ///
    /// Maps view routes to their URL paths:
    /// - Verify: `/mfa/verify`
    /// - Manage: `/mfa/manage`
    /// - TOTP: `/mfa/totp/...`
    /// - Backup codes: `/mfa/backup-codes/...`
    public static var router: some HTTP.Router.`Protocol`<Identity.MFA.View> {
        Coder::Case(
            Identity.MFA.View.cases.verify.prism,
            Identity.MFA.View.cases.verify.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("verify")
            Coder::Coder(
                { Identity.MFA.URLChallenge(sessionToken: $0.first, attemptsRemaining: $0.second) },
                from: { Pair($0.sessionToken, $0.attemptsRemaining) }
            ) {
                HTTP.Query.Field<String>("sessionToken")
                HTTP.Query.Field<Int>("attemptsRemaining", default: 3)
            }
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.View.cases.manage.prism,
            Identity.MFA.View.cases.manage.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("manage")
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.View.cases.totp.prism,
            Identity.MFA.View.cases.totp.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("totp")
            Identity.MFA.View.TOTP.router
        }

        Coder::Case(
            Identity.MFA.View.cases.backupCodes.prism,
            Identity.MFA.View.cases.backupCodes.fold,
            absent: .mismatch
        ) {
            HTTP.Segment("backup-codes")
            Identity.MFA.View.BackupCodes.router
        }
    }
}

extension Identity.MFA.View.TOTP: HTTP.Routable {
    /// Router for TOTP view endpoints.
    public static var router: some HTTP.Router.`Protocol`<Identity.MFA.View.TOTP> {
        Coder::Case(
            Identity.MFA.View.TOTP.cases.setup.prism,
            Identity.MFA.View.TOTP.cases.setup.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("setup")
            HTTP.Segment.End()
        }

        // Support both /confirm-setup and /confirm
        Coder::Case(
            Identity.MFA.View.TOTP.cases.confirmSetup.prism,
            Identity.MFA.View.TOTP.cases.confirmSetup.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("confirm-setup")
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.View.TOTP.cases.confirmSetup.prism,
            Identity.MFA.View.TOTP.cases.confirmSetup.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("confirm")
            HTTP.Segment.End()
        }

        Coder::Case(
            Identity.MFA.View.TOTP.cases.manage.prism,
            Identity.MFA.View.TOTP.cases.manage.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("manage")
            HTTP.Segment.End()
        }
    }
}

extension Identity.MFA.View.BackupCodes: HTTP.Routable {
    /// Router for backup codes view endpoints.
    public static var router: some HTTP.Router.`Protocol`<Identity.MFA.View.BackupCodes> {
        // Handle /verify first to avoid ambiguity
        Coder::Case(
            Identity.MFA.View.BackupCodes.cases.verify.prism,
            Identity.MFA.View.BackupCodes.cases.verify.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("verify")
            Coder::Coder(
                { Identity.MFA.URLChallenge(sessionToken: $0.first, attemptsRemaining: $0.second) },
                from: { Pair($0.sessionToken, $0.attemptsRemaining) }
            ) {
                HTTP.Query.Field<String>("sessionToken")
                HTTP.Query.Field<Int>("attemptsRemaining", default: 3)
            }
            HTTP.Segment.End()
        }

        // /display is explicit
        Coder::Case(
            Identity.MFA.View.BackupCodes.cases.display.prism,
            Identity.MFA.View.BackupCodes.cases.display.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment("display")
            HTTP.Segment.End()
        }

        // Default to display when no subpath
        Coder::Case(
            Identity.MFA.View.BackupCodes.cases.display.prism,
            Identity.MFA.View.BackupCodes.cases.display.fold,
            absent: .mismatch
        ) {
            HTTP.Method.get
            HTTP.Segment.End()
        }
    }
}
