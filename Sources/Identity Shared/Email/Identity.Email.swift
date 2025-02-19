//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 18/02/2025.
//

import EmailAddress
import Foundation
import URLRouting

extension Identity {
    public enum Email {}
}

extension Identity.Email {
    public enum Change {}
}

extension Identity.Email.Change {
    public typealias Reauthorization = Identity.Reauthorization
}

extension Identity.Email.Change {
    public struct Request: Codable, Hashable, Sendable {
        public let newEmail: String

        public init(
            newEmail: String = ""
        ) {
            self.newEmail = newEmail
        }

        public enum CodingKeys: String, CodingKey {
            case newEmail
        }
    }
}

extension Identity.Email.Change.Request {
    public init(
        newEmail: EmailAddress
    ) {
        self.newEmail = newEmail.rawValue
    }
}

extension Identity.Email.Change.Request {
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.Email.Change.Request> {
            Method.post
            Path.request
            Body(.form(Identity.Email.Change.Request.self, decoder: .default))
        }
    }
}

extension Identity.Email.Change {
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

extension Identity.Email.Change.Confirm {
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.Email.Change.Confirm> {
            Method.post
            Path.confirm
            Body(.form(Identity.Email.Change.Confirm.self, decoder: .default))
        }
    }
}

extension Identity.Email.Change.Request {
    public enum Error: Swift.Error, Sendable {
        case unauthorized
        case emailIsNil
    }
}

extension Identity.Client.Email.Change {
    public enum Request { }
}

extension Identity.Email.Change.Request {
    public enum Result: Codable, Hashable, Sendable {
        case success
        case requiresReauthentication
    }
}

extension Identity.Email.Change.Confirm {
    public typealias Response = Identity.Authentication.Response
}
