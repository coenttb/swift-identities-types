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
    public enum Password: Codable, Hashable, Sendable {
        case reset(Identity.Consumer.View.Password.Reset)
        case change(Identity.Consumer.View.Password.Change)
    }
}

extension Identity.Consumer.View.Password {
    public enum Reset: Codable, Hashable, Sendable {
        case request
        case confirm(Identity.Consumer.View.Password.Reset.Confirm)
    }
    
    public enum Change: Codable, Hashable, Sendable {
        case request
    }
}

extension Identity.Consumer.View.Password.Change {
    public enum Request {}
}

extension Identity.Consumer.View.Password.Reset {
    public enum Request {}
}

extension Identity.Consumer.View.Password.Reset {
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
