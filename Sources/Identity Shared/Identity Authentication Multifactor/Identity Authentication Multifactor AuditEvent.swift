//
//  Identity.Authenticate.Multifactor.AuditEvent.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Foundation

extension Identity.Authentication.Multifactor {
    public enum Audit {}
}

extension Identity.Authentication.Multifactor.Audit {
    public struct Event: Codable, Hashable, Sendable {
        public let userId: String
        public let type: Identity.Authentication.Multifactor.Audit.Event.`Type`
        public let method: Identity.Authentication.Multifactor.Method?
        public let timestamp: Date
        public let metadata: [String: String]

        public init(
            userId: String,
            eventType: `Type`,
            method: Identity.Authentication.Multifactor.Method? = nil,
            timestamp: Date = .now,
            metadata: [String: String] = [:]
        ) {
            self.userId = userId
            self.type = eventType
            self.method = method
            self.timestamp = timestamp
            self.metadata = metadata
        }
    }
}

extension Identity.Authentication.Multifactor.Audit.Event {
    public enum `Type`: String, Codable, Hashable, Sendable {
        case setupInitiated = "SetupInitiated"
        case setupCompleted = "SetupCompleted"
        case verificationSucceeded = "VerificationSucceeded"
        case verificationFailed = "VerificationFailed"
        case disabled = "Disabled"
        case forceDisabled = "ForceDisabled"
        case methodAdded = "MethodAdded"
        case methodRemoved = "MethodRemoved"
        case methodReset = "MethodReset"
        case recoveryCodesGenerated = "RecoveryCodesGenerated"
        case recoveryCodeUsed = "RecoveryCodeUsed"
        case bypassUsed = "BypassUsed"
    }
}
