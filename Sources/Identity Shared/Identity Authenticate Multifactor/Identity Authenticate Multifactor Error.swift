//
//  MultifactorAuthentication.Error.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Foundation

// Error types
extension Identity.Authenticate.Multifactor {
    public enum Error: Swift.Error, Sendable {
        case invalidMethod
        case invalidCode
        case expiredChallenge
        case invalidChallenge
        case tooManyAttempts
        case methodNotEnabled
        case alreadyEnabled
        case noRemainingCodes
    }
}
