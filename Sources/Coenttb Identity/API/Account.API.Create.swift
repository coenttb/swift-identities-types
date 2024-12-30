//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

import Coenttb_Web

extension Coenttb_Identity.API {
    public enum Create: Equatable, Sendable {
        case request(Coenttb_Identity.API.Create.Request)
        case verify(Coenttb_Identity.API.Create.Verify)
    }
}

extension Coenttb_Identity.API.Create {
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
        
        package enum CodingKeys: String, CodingKey {
            case email
            case password
        }
    }
}

extension Coenttb_Identity.API.Create.Request {
    public init(
        email: EmailAddress,
        password: String
    ){
        self.email = email.rawValue
        self.password = password
    }
}

extension Coenttb_Identity.API.Create {
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

extension Coenttb_Identity.API.Create.Verify {
    public init(
        email: EmailAddress,
        token: String
    ){
        self.email = email.rawValue
        self.token = token
    }
}

extension Coenttb_Identity.API.Create {
    public struct Router: ParserPrinter, Sendable {
        
        public init(){}
        
        public var body: some URLRouting.Router<Coenttb_Identity.API.Create> {
            OneOf {
                URLRouting.Route(.case(Coenttb_Identity.API.Create.request)) {
                    Method.post
                    Path { "request" }
                    Body(.form(Coenttb_Identity.API.Create.Request.self, decoder: .default))
                }
                URLRouting.Route(.case(Coenttb_Identity.API.Create.verify)) {
                    Method.post
                    Path { "verify" }
                    Parse(.memberwise(Coenttb_Identity.API.Create.Verify.init)) {
                        Query {
                            Field(Coenttb_Identity.API.Verify.CodingKeys.token.rawValue, .string)
                            Field(Coenttb_Identity.API.Verify.CodingKeys.email.rawValue, .string)
                        }
                    }
                }
            }
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
