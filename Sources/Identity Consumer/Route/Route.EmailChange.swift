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
    public enum EmailChange: Codable, Hashable, Sendable {
        case request
        case confirm(EmailChange.Confirm)
    }
}

extension Route.EmailChange {
    
    public enum Request {}
    public struct Confirm: Codable, Hashable, Sendable {
        public let token: String
        
        public init(
            token: String = ""
        ) {
            self.token = token
        }
        
        public enum CodingKeys: String, CodingKey {
            case token
        }
    }
}


