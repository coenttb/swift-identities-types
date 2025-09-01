//
//  Identity.MFA.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Foundation

extension Identity {
    /// Namespace for MFA-related types.
    public enum MFA {}
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
    
    /// MFA status for an identity.
    public struct Status: Codable, Equatable, Sendable {
        public let configured: ConfiguredMethods
        public let isRequired: Bool
        
        public init(configured: ConfiguredMethods, isRequired: Bool) {
            self.configured = configured
            self.isRequired = isRequired
        }
    }
    
    /// Configured MFA methods.
    public struct ConfiguredMethods: Codable, Equatable, Sendable {
        public let totp: Bool
        public let sms: Bool
        public let email: Bool
        public let webauthn: Bool
        public let backupCodesRemaining: Int
        
        public init(
            totp: Bool = false,
            sms: Bool = false,
            email: Bool = false,
            webauthn: Bool = false,
            backupCodesRemaining: Int = 0
        ) {
            self.totp = totp
            self.sms = sms
            self.email = email
            self.webauthn = webauthn
            self.backupCodesRemaining = backupCodesRemaining
        }
        
        public var availableMethods: Set<Method> {
            var methods = Set<Method>()
            if totp { methods.insert(.totp) }
            if sms { methods.insert(.sms) }
            if email { methods.insert(.email) }
            if webauthn { methods.insert(.webauthn) }
            if backupCodesRemaining > 0 { methods.insert(.backupCode) }
            return methods
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
