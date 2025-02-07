//
//  MultifactorAuthentication.Challenge.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Foundation

extension Identity.Authenticate.Multifactor {
    public struct Challenge: Codable, Hashable, Sendable {
        public let id: String
        public let method: Method
        public let createdAt: Date
        public let expiresAt: Date
        
        public init(
            id: String = "",
            method: Method,
            createdAt: Date = Date(),
            expiresAt: Date = Date().addingTimeInterval(300) // 5 minutes default
        ) {
            self.id = id
            self.method = method
            self.createdAt = createdAt
            self.expiresAt = expiresAt
        }
    }
}
