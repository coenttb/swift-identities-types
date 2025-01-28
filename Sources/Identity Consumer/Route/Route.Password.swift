//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 29/01/2025.
//

import Coenttb_Web
import CasePaths
import Identity_Shared

extension Route {
    public enum Password: Codable, Hashable, Sendable {
        case reset(Route.Password.Reset)
        case change(Route.Password.Change)
    }
}

extension Route.Password {
    public enum Reset: Codable, Hashable, Sendable {
        case request
        case confirm(Route.Password.Reset.Confirm)
    }
    
    public enum Change: Codable, Hashable, Sendable {
        case request
    }
}

extension Route.Password.Change {
    public enum Request {}
}

extension Route.Password.Reset {
    public enum Request {}
}

extension Route.Password.Reset {
    public struct Confirm: Codable, Hashable, Sendable {
        public let token: String
        public let newPassword: String
        
        public init(
            token: String = "",
            newPassword: String = ""
        ) {
            self.token = token
            self.newPassword = newPassword
        }
        
        public enum CodingKeys: String, CodingKey {
            case token
            case newPassword
        }
    }
}
