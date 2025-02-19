//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import SwiftWeb

extension Identity {
    public enum Creation {}
}

extension Identity.Creation {
    public struct Request: Codable, Hashable, Sendable {
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

extension Identity.Creation.Request {
    public init(
        email: EmailAddress,
        password: String
    ) {
        self.email = email.rawValue
        self.password = password
    }
}

extension Identity.Creation.Request {
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.Creation.Request> {
            Method.post
            Path.request
            Body(.form(Identity.Creation.Request.self, decoder: .default))
        }
    }
}

extension Identity.Creation {
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

extension Identity.Creation.Verify {
    public init(
        token: String,
        email: EmailAddress
    ) {
        self.token = token
        self.email = email.rawValue
    }
}

extension Identity.Creation.Verify {
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.Creation.Verify> {
            Method.post
            Path.verify
            Body(.form(Identity.Creation.Verify.self, decoder: .default))
        }
    }
}
