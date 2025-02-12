//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 05/02/2025.
//

import Foundation

extension JWT {
    
    
    public struct Token: Codable, Hashable, Sendable {
        public let value: String
        public let type: String
        public let expiresIn: TimeInterval
        
        public init(
            value: String,
            type: String = "Bearer",
            expiresIn: TimeInterval
        ) {
            self.value = value
            self.type = type
            self.expiresIn = expiresIn
        }
        
        public enum CodingKeys: String, CodingKey {
            case value = "token"
            case type
            case expiresIn = "exp"
        }
    }
}
