//
//  Identity.Authenticate.Multifactor.AuditEvent.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Foundation

extension Identity.Authenticate.Multifactor {
    public enum Audit {}
}

extension Identity.Authenticate.Multifactor.Audit {
    public struct Event: Codable, Hashable, Sendable {
        public let userId: String
        public let type: Identity.Authenticate.Multifactor.Audit.Event.`Type`
        public let method: Identity.Authenticate.Multifactor.Method?
        public let timestamp: Date
        public let metadata: [String: String]
        
        public init(
            userId: String,
            eventType: `Type`,
            method: Identity.Authenticate.Multifactor.Method? = nil,
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

extension Identity.Authenticate.Multifactor.Audit.Event {
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
