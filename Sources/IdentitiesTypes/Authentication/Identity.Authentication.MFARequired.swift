//
//  Identity.Authentication.MFARequired.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 21/08/2025.
//

import Foundation

extension Identity.Authentication {
    /// Error thrown when MFA is required for authentication to complete.
    ///
    /// This error is thrown when credentials are valid but the account has MFA enabled,
    /// requiring an additional verification step.
    public struct MFARequired: Error, Codable, Sendable {
        /// Session token for the MFA challenge
        public let sessionToken: String
        
        /// Available MFA methods for this account
        public let availableMethods: Set<Identity.MFA.Method>
        
        /// Number of attempts remaining before lockout
        public let attemptsRemaining: Int
        
        /// Expiration time for the MFA challenge
        public let expiresAt: Date
        
        public init(
            sessionToken: String,
            availableMethods: Set<Identity.MFA.Method>,
            attemptsRemaining: Int = 3,
            expiresAt: Date = Date().addingTimeInterval(300) // 5 minutes
        ) {
            self.sessionToken = sessionToken
            self.availableMethods = availableMethods
            self.attemptsRemaining = attemptsRemaining
            self.expiresAt = expiresAt
        }
    }
}
