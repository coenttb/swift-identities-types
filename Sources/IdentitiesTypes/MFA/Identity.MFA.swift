//
//  Identity.MFA.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Foundation

extension Identity {
    /// Namespace for MFA-related functionality within the Identity system.
    public struct MFA: @unchecked Sendable {
        public var totp: Identity.MFA.TOTP
        public var sms: Identity.MFA.SMS
        public var email: Identity.MFA.Email
        public var webauthn: Identity.MFA.WebAuthn
        public var backupCodes: Identity.MFA.BackupCodes
        public var status: Identity.MFA.Status
        public var router: any URLRouting.Router<Identity.MFA.Route>
        
        public init(
            totp: Identity.MFA.TOTP,
            sms: Identity.MFA.SMS,
            email: Identity.MFA.Email,
            webauthn: Identity.MFA.WebAuthn,
            backupCodes: Identity.MFA.BackupCodes,
            status: Identity.MFA.Status,
            router: any URLRouting.Router<Identity.MFA.Route> = Identity.MFA.Route.Router()
        ) {
            self.totp = totp
            self.sms = sms
            self.email = email
            self.webauthn = webauthn
            self.backupCodes = backupCodes
            self.status = status
            self.router = router
        }
    }
}

// MARK: - Common Types

extension Identity.MFA {
    /// Request to disable an MFA method.
    public struct DisableRequest: Codable, Equatable, Sendable {
        public let reauthorizationToken: String
        
        public init(reauthorizationToken: String) {
            self.reauthorizationToken = reauthorizationToken
        }
    }
    
    /// Available MFA methods.
    public enum Method: String, Codable, CaseIterable, Sendable {
        case totp
        case sms
        case email
        case webauthn
        case backupCode
        
        public var displayName: String {
            switch self {
            case .totp: return "Authenticator App"
            case .sms: return "SMS"
            case .email: return "Email"
            case .webauthn: return "Security Key"
            case .backupCode: return "Backup Code"
            }
        }
    }
    
    /// MFA challenge presented after initial authentication.
    public struct Challenge: Codable, Hashable, Sendable {
        public let sessionToken: String
        public let availableMethods: Set<Method>
        public let expiresAt: Date
        public let attemptsRemaining: Int
        
        public init(
            sessionToken: String,
            availableMethods: Set<Method>,
            expiresAt: Date,
            attemptsRemaining: Int = 3
        ) {
            self.sessionToken = sessionToken
            self.availableMethods = availableMethods
            self.expiresAt = expiresAt
            self.attemptsRemaining = attemptsRemaining
        }
    }
    
    /// Simplified MFA challenge for URL routing.
    ///
    /// This struct contains only the essential fields that can be easily
    /// represented in URL query parameters. The full challenge data
    /// (available methods, expiration) is maintained server-side and
    /// looked up using the session token.
    public struct URLChallenge: Codable, Hashable, Sendable {
        public let sessionToken: String
        public let attemptsRemaining: Int
        
        public init(
            sessionToken: String,
            attemptsRemaining: Int = 3
        ) {
            self.sessionToken = sessionToken
            self.attemptsRemaining = attemptsRemaining
        }
        
        /// Creates a URLChallenge from a full Challenge.
        public init(from challenge: Challenge) {
            self.sessionToken = challenge.sessionToken
            self.attemptsRemaining = challenge.attemptsRemaining
        }
    }
}
