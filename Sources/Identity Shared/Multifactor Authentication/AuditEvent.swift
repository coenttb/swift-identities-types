//
//  MultifactorAuthentication.AuditEvent.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Foundation

extension MultifactorAuthentication {
    public enum Audit {}
}

extension MultifactorAuthentication.Audit {
    public struct Event: Codable, Hashable, Sendable {
        public let userId: String
        public let type: MultifactorAuthentication.Audit.Event.`Type`
        public let method: MultifactorAuthentication.Method?
        public let timestamp: Date
        public let metadata: [String: String]
        
        public init(
            userId: String,
            eventType: `Type`,
            method: MultifactorAuthentication.Method? = nil,
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

extension MultifactorAuthentication.Audit.Event {
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
