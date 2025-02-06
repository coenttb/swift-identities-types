//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 05/02/2025.
//

import Foundation

extension JWT {
    public struct Response: Codable, Hashable, Sendable {
        public let token: String
        public var type: String { "Bearer" }
        public let expiresIn: TimeInterval
        
        enum CodingKeys: String, CodingKey {
            case token = "token"
            case expiresIn = "exp"
        }
        
        public init(token: String, expiresIn: TimeInterval) {
            self.token = token
            self.expiresIn = expiresIn
        }
    }
}
