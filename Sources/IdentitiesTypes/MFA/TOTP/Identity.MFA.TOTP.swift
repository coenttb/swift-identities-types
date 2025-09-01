//
//  Identity.MFA.TOTP.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Foundation

extension Identity.MFA {
    /// TOTP-specific types and operations.
    public enum TOTP {}
}

extension Identity.MFA.TOTP {
    /// Response from TOTP setup initialization.
    public struct SetupResponse: Codable, Equatable, Sendable {
        public let secret: String  // Base32 encoded
        public let qrCodeURL: URL  // otpauth:// URL
        public let manualEntryKey: String  // Formatted for manual entry
        
        public init(secret: String, qrCodeURL: URL, manualEntryKey: String) {
            self.secret = secret
            self.qrCodeURL = qrCodeURL
            self.manualEntryKey = manualEntryKey
        }
    }
    
    /// Request to confirm TOTP setup.
    public struct ConfirmSetup: Codable, Equatable, Sendable {
        public let code: String
        
        public init(code: String) {
            self.code = code
        }
    }
    
    /// Request to verify TOTP code.
    public struct Verify: Codable, Equatable, Sendable {
        public let code: String
        public let sessionToken: String
        
        public init(code: String, sessionToken: String) {
            self.code = code
            self.sessionToken = sessionToken
        }
    }
}