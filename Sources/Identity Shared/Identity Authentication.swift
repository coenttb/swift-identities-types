//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import BearerAuth
import Coenttb_Authentication
import Coenttb_Web
import EmailAddress

extension Identity {
    public enum Authentication: Equatable, Sendable {
        case credentials(Credentials)
        case token(Identity.Authentication.Token)
    }
}

extension Identity.Authentication {
    public struct Credentials: Codable, Hashable, Sendable {
        public let username: String
        public let password: String

        public init(
            username: String = "",
            password: String = ""
        ) {
            self.username = username
            self.password = password
        }

        public enum CodingKeys: String, CodingKey {
            case username
            case password
        }
    }
}

extension Identity.Authentication.Credentials {
    public init(
        email: EmailAddress,
        password: String
    ) {
        self = .init(username: email.rawValue, password: password)
    }
}

extension Identity.Authentication {
    public enum Token: Equatable, Sendable {
        case access(BearerAuth)
        case refresh(BearerAuth)
    }
}

extension Identity.Authentication {
    public struct Response: Codable, Hashable, Sendable {
        public let accessToken: JWT.Token
        public let refreshToken: JWT.Token

        public init(
            accessToken: JWT.Token,
            refreshToken: JWT.Token
        ) {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
        }
    }
}
