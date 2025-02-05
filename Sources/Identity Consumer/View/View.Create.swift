//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 29/01/2025.
//

import Coenttb_Web
import CasePaths
import Identity_Shared

extension Identity.Consumer.View {
    public enum Create: Codable, Hashable, Sendable {
        case request
        case verify(Identity.Create.Verify)
    }
}

extension Identity.Consumer.View.Create {
    public struct Verify: Codable, Hashable, Sendable {
        public let token: String
        public let email: String
        
        public init(
            token: String = "",
            email: String = ""
        ) {
            self.token = token
            self.email = email
        }
        
        public enum CodingKeys: String, CodingKey {
            case token
            case email
        }
    }
}
