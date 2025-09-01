//
//  Identity.MFA.BackupCodes.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Foundation

extension Identity.MFA {
    /// BackupCodes-specific types and operations.
    public enum BackupCodes {}
}

extension Identity.MFA.BackupCodes {
    /// Request to verify a backup code.
    public struct Verify: Codable, Equatable, Sendable {
        public let code: String
        public let sessionToken: String
        
        public init(code: String, sessionToken: String) {
            self.code = code
            self.sessionToken = sessionToken
        }
    }
    
    /// Response with generated backup codes.
    public struct RegenerateResponse: Codable, Equatable, Sendable {
        public let codes: [String]
        
        public init(codes: [String]) {
            self.codes = codes
        }
    }
}