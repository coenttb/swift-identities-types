//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import Coenttb_Web

public enum Create {}

extension Create {
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

extension Create.Request {
    public init(
        email: EmailAddress,
        password: String
    ){
        self.email = email.rawValue
        self.password = password
    }
}

extension Identity_Shared.Create.Request {
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}

        public var body: some URLRouting.Router<Identity_Shared.Create.Request> {
            Method.post
            Path.request
            Body(.form(Identity_Shared.Create.Request.self, decoder: .default))
        }
    }
}

extension Create {
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

extension Create.Verify {
    public init(
        email: EmailAddress,
        token: String
    ){
        self.email = email.rawValue
        self.token = token
    }
}

extension Identity_Shared.Create.Verify {
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}

        public var body: some URLRouting.Router<Identity_Shared.Create.Verify> {
            Method.post
            Path.verify
            Body(.form(Identity_Shared.Create.Verify.self, decoder: .default))
        }
    }
}

extension UrlFormDecoder {
    fileprivate static var `default`: UrlFormDecoder {
        let decoder = UrlFormDecoder()
        decoder.parsingStrategy = .bracketsWithIndices
        return decoder
    }
}
