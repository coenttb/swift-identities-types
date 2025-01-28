//
//  MultifactorAuthentication.Method.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Foundation


extension MultifactorAuthentication {
    public enum Method: String, Codable, Hashable, Sendable, CaseIterable {
        case totp = "TOTP"
        case sms = "SMS"
        case email = "Email"
        case recoveryCode = "RecoveryCode"
    }
}
