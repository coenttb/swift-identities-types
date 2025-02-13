//
//  MultifactorAuthentication.Configuration.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Foundation

extension Identity.Authentication.Multifactor {
    public struct Configuration: Codable, Hashable, Sendable {
        public let methods: Set<Method>
        public let status: Status
        public let lastVerifiedAt: Date?

        public init(
            methods: Set<Method> = [],
            status: Status = .disabled,
            lastVerifiedAt: Date? = nil
        ) {
            self.methods = methods
            self.status = status
            self.lastVerifiedAt = lastVerifiedAt
        }
    }
}
