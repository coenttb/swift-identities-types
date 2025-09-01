//
//  Identity.MFA.SMS.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Foundation

extension Identity.MFA {
    /// SMS-specific types and operations.
    public enum SMS {}
}

extension Identity.MFA.SMS {
    /// Request to setup SMS MFA.
    public struct Setup: Codable, Equatable, Sendable {
        public let phoneNumber: String
        
        public init(phoneNumber: String) {
            self.phoneNumber = phoneNumber
        }
    }
    
    /// Request to verify SMS code.
    public struct Verify: Codable, Equatable, Sendable {
        public let code: String
        public let sessionToken: String
        
        public init(code: String, sessionToken: String) {
            self.code = code
            self.sessionToken = sessionToken
        }
    }
    
    /// Request to update phone number.
    public struct UpdatePhoneNumber: Codable, Equatable, Sendable {
        public let phoneNumber: String
        public let reauthorizationToken: String
        
        public init(phoneNumber: String, reauthorizationToken: String) {
            self.phoneNumber = phoneNumber
            self.reauthorizationToken = reauthorizationToken
        }
    }
}