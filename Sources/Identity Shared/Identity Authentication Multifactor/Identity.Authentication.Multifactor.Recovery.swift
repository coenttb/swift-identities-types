//
//  MultifactorAuthentication.Recovery.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Foundation

// Recovery codes management
extension Identity.Authentication.Multifactor {
    public enum Recovery {}
}

extension Identity.Authentication.Multifactor.Recovery {
    public struct Codes: Codable, Hashable, Sendable {
        public let codes: [String]
        public let usedCodes: Set<String>

        public init(
            codes: [String] = [],
            usedCodes: Set<String> = []
        ) {
            self.codes = codes
            self.usedCodes = usedCodes
        }

        public var remainingCodes: Int {
            codes.count - usedCodes.count
        }
    }
}
