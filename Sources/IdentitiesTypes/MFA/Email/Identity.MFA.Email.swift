//
//  Identity.MFA.Email.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import TypesFoundation

extension Identity.MFA {
    /// Email-specific types and operations.
    public struct Email: @unchecked Sendable {
        public var client: Identity.MFA.Email.Client
        public var router: any URLRouting.Router<Identity.MFA.Email.API>
        
        public init(
            client: Identity.MFA.Email.Client,
            router: any URLRouting.Router<Identity.MFA.Email.API> = Identity.MFA.Email.API.Router()
        ) {
            self.client = client
            self.router = router
        }
    }
}

extension Identity.MFA.Email {
    /// Request to setup email MFA.
    public struct Setup: Codable, Equatable, Sendable {
        public let email: String
        
        public init(email: String) {
            self.email = email
        }
    }
    
    /// Request to verify email code.
    public struct Verify: Codable, Equatable, Sendable {
        public let code: String
        public let sessionToken: String
        
        public init(code: String, sessionToken: String) {
            self.code = code
            self.sessionToken = sessionToken
        }
    }
    
    /// Request to update email for MFA.
    public struct UpdateEmail: Codable, Equatable, Sendable {
        public let email: String
        public let reauthorizationToken: String
        
        public init(email: String, reauthorizationToken: String) {
            self.email = email
            self.reauthorizationToken = reauthorizationToken
        }
    }
}
