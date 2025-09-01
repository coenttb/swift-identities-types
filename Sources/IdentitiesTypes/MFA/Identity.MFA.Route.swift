//
//  Identity.MFA.Route.swift
//  swift-identities
//
//  Feature-based routing for MFA functionality
//

import CasePaths
import ServerFoundation

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
    @CasePathable
    @dynamicMemberLookup
    public enum Route: Equatable, Sendable {
        /// API endpoints for MFA operations
        case api(API)
        
        /// View endpoints for MFA pages
        case view(View)
    }
}

extension Identity.MFA {
    /// API endpoints for MFA management.
    ///
    /// Inherits from the existing Identity.API.MFA structure
    /// to maintain backward compatibility while enabling feature-based organization.
    public typealias API = Identity.API.MFA
}

extension Identity.MFA {
    /// View routes for MFA pages.
    ///
    /// Provides frontend routes for MFA-related operations.
    @CasePathable
    @dynamicMemberLookup
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
        @CasePathable
        @dynamicMemberLookup
        public enum TOTP: Equatable, Sendable {
            /// TOTP setup page
            case setup
            
            /// TOTP setup confirmation page
            case confirmSetup
            
            /// TOTP management page
            case manage
        }
        
        /// Backup codes view endpoints
        @CasePathable
        @dynamicMemberLookup
        public enum BackupCodes: Equatable, Sendable {
            /// Display newly generated backup codes
            case display
            
            /// Verify using backup code during login
            case verify(Identity.MFA.URLChallenge)
        }
    }
}

extension Identity.MFA.Route {
    /// Router for the complete MFA feature including both API and View routes.
    ///
    /// URL structure:
    /// - API routes: `/api/mfa/...`
    /// - View routes: `/mfa/...`
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.MFA.Route> {
            OneOf {
                // API routes under /api prefix
                URLRouting.Route(.case(Identity.MFA.Route.api)) {
                    Path { "api" }
                    Path { "mfa" }
                    Identity.API.MFA.Router()
                }
                
                // View routes (no /api prefix)
                URLRouting.Route(.case(Identity.MFA.Route.view)) {
                    Path { "mfa" }
                    Identity.MFA.View.Router()
                }
            }
        }
    }
}

extension Identity.MFA.View {
    /// Router for MFA view endpoints.
    ///
    /// Maps view routes to their URL paths:
    /// - Verify: `/mfa/verify`
    /// - Manage: `/mfa/manage`
    /// - TOTP: `/mfa/totp/...`
    /// - Backup codes: `/mfa/backup-codes/...`
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.MFA.View> {
            OneOf {
                URLRouting.Route(.case(Identity.MFA.View.verify)) {
                    Path { "verify" }
                    Parse(.memberwise(Identity.MFA.URLChallenge.init)) {
                        Query {
                            Field("sessionToken")
                            Field("attemptsRemaining", default: 3) { Digits() }
                        }
                    }
                }
                
                URLRouting.Route(.case(Identity.MFA.View.manage)) {
                    Path { "manage" }
                }
                
                URLRouting.Route(.case(Identity.MFA.View.totp)) {
                    Path { "totp" }
                    Identity.MFA.View.TOTP.Router()
                }
                
                URLRouting.Route(.case(Identity.MFA.View.backupCodes)) {
                    Path { "backup-codes" }
                    Identity.MFA.View.BackupCodes.Router()
                }
            }
        }
    }
}

extension Identity.MFA.View.TOTP {
    /// Router for TOTP view endpoints.
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.MFA.View.TOTP> {
            OneOf {
                URLRouting.Route(.case(Identity.MFA.View.TOTP.setup)) {
                    Path { "setup" }
                }
                
                // Support both /confirm-setup and /confirm
                URLRouting.Route(.case(Identity.MFA.View.TOTP.confirmSetup)) {
                    Path { "confirm-setup" }
                }
                
                URLRouting.Route(.case(Identity.MFA.View.TOTP.confirmSetup)) {
                    Path { "confirm" }
                }
                
                URLRouting.Route(.case(Identity.MFA.View.TOTP.manage)) {
                    Path { "manage" }
                }
            }
        }
    }
}

extension Identity.MFA.View.BackupCodes {
    /// Router for backup codes view endpoints.
    public struct Router: ParserPrinter, Sendable {
        public init() {}
        
        public var body: some URLRouting.Router<Identity.MFA.View.BackupCodes> {
            OneOf {
                // Handle /verify first to avoid ambiguity
                URLRouting.Route(.case(Identity.MFA.View.BackupCodes.verify)) {
                    Path { "verify" }
                    Parse(.memberwise(Identity.MFA.URLChallenge.init)) {
                        Query {
                            Field("sessionToken")
                            Field("attemptsRemaining", default: 3) { Digits() }
                        }
                    }
                }
                
                // /display is explicit
                URLRouting.Route(.case(Identity.MFA.View.BackupCodes.display)) {
                    Path { "display" }
                }
                
                // Default to display when no subpath
                URLRouting.Route(.case(Identity.MFA.View.BackupCodes.display)) {
                    // Empty path - defaults to display
                }
            }
        }
    }
}
