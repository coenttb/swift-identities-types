//
//  Identity.Password.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import SwiftWeb

extension Identity {
    public enum Password {}
}

extension Identity.Password {
    public enum Reset {}
}

extension Identity.Password.Reset {
    public struct Request: Codable, Hashable, Sendable {
        public let email: String

        public init(
            email: String = ""
        ) {
            self.email = email
        }

        public enum CodingKeys: String, CodingKey {
            case email
        }
    }
}

extension Identity.Password.Reset.Request {
    public init(
        email: EmailAddress
    ) {
        self.email = email.rawValue
    }
}

extension Identity.Password.Reset.Request {
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.Password.Reset.Request> {
            Method.post
            Path.request
            Body(.form(Identity.Password.Reset.Request.self, decoder: .default))
        }
    }
}

extension Identity.Password.Reset {
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

extension Identity.Password.Reset.Confirm {
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.Password.Reset.Confirm> {
            Method.post
            Path.confirm
            Body(.form(Identity.Password.Reset.Confirm.self, decoder: .default))
        }
    }
}

extension Identity.Password {
    public enum Change {}
}

extension Identity.Password.Change {
    public typealias Reauthorization = Identity.Reauthorization
}

extension Identity.Password.Change {
    public struct Request: Codable, Hashable, Sendable {
        public let currentPassword: String
        public let newPassword: String

        public init(
            currentPassword: String = "",
            newPassword: String = ""
        ) {
            self.currentPassword = currentPassword
            self.newPassword = newPassword
        }

        public enum CodingKeys: String, CodingKey {
            case currentPassword
            case newPassword
        }
    }
}

extension Identity.Password.Change.Request {
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.Password.Change.Request> {
            Method.post
            Path.request
            Body(.form(Identity.Password.Change.Request.self, decoder: .default))
        }
    }
}
