//
//  Identity.MFA.Status.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import TypesFoundation

extension Identity.MFA {
    /// Status-specific types and operations.
    public struct Status: @unchecked Sendable {
        public var client: Identity.MFA.Status.Client
        public var router: any URLRouting.Router<Identity.MFA.Status.API>
        
        public init(
            client: Identity.MFA.Status.Client,
            router: any URLRouting.Router<Identity.MFA.Status.API> = Identity.MFA.Status.API.Router()
        ) {
            self.client = client
            self.router = router
        }
    }
}

extension Identity.MFA.Status {
    /// MFA status response for an identity.
    public struct Response: Codable, Equatable, Sendable {
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
        
        public var availableMethods: Set<Identity.MFA.Method> {
            var methods = Set<Identity.MFA.Method>()
            if totp { methods.insert(.totp) }
            if sms { methods.insert(.sms) }
            if email { methods.insert(.email) }
            if webauthn { methods.insert(.webauthn) }
            if backupCodesRemaining > 0 { methods.insert(.backupCode) }
            return methods
        }
    }
}
