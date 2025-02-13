//
//  MultifactorAuthentication.Verification.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Foundation

extension Identity.Authentication.Multifactor {
    public struct Verification: Codable, Hashable, Sendable {
        public let challengeId: String
        public let code: String

        public init(
            challengeId: String = "",
            code: String = ""
        ) {
            self.challengeId = challengeId
            self.code = code
        }
    }
}
