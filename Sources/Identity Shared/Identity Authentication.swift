//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import Coenttb_Web
import EmailAddress
import Coenttb_Authentication
import BearerAuth

extension Identity {
    public enum Authentication: Equatable, Sendable {
        case credentials(Credentials)
        case bearer(BearerAuth)
    }
}

extension Identity.Authentication {
    public struct Credentials: Codable, Hashable, Sendable {
        public let email: String
        public let password: String
    
        public init(
            email: String = "",
            password: String = ""
        ) {
            self.email = email
            self.password = password
        }
    
        public enum CodingKeys: String, CodingKey {
            case email
            case password
        }
    }
}

extension Identity.Authentication.Credentials {
    public init(
        email: EmailAddress,
        password: String
    ){
        self = .init(email: email.rawValue, password: password)
    }
}

