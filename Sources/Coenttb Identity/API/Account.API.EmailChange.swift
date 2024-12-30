//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

import Coenttb_Web

extension Coenttb_Identity.API {
    public enum EmailChange: Equatable, Sendable {
        case reauthorization(Coenttb_Identity.API.EmailChange.Reauthorization)
        case request(Coenttb_Identity.API.EmailChange.Request)
        case confirm(Coenttb_Identity.API.EmailChange.Confirm)
    }
}

extension Coenttb_Identity.API.EmailChange {
    public struct Reauthorization: Codable, Hashable, Sendable {
        public let password: String
        
        public init(
            password: String = ""
        ){
            self.password = password
        }
        
        public enum CodingKeys: String, CodingKey {
            case password
        }
    }
}
 
extension Coenttb_Identity.API.EmailChange {
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

extension Coenttb_Identity.API.EmailChange.Request {
    public init(
        newEmail: EmailAddress
    ){
        self.newEmail = newEmail.rawValue
    }
}
 
extension Coenttb_Identity.API.EmailChange {
    public struct Confirm: Codable, Hashable, Sendable {
        public let token: String
        public let newEmail: String
        
        public init(
            token: String = "",
            newEmail: String = ""
        ) {
            self.token = token
            self.newEmail = newEmail
        }
        
        public enum CodingKeys: String, CodingKey {
            case token
            case newEmail
        }
    }
}

extension Coenttb_Identity.API.EmailChange.Confirm {
    public init(
        token: String,
        newEmail: EmailAddress
    ){
        self.token = token
        self.newEmail = newEmail.rawValue
    }
}

extension Coenttb_Identity.API.EmailChange {
    public struct Router: ParserPrinter, Sendable {
        
        public init(){}
        
        public var body: some URLRouting.Router<Coenttb_Identity.API.EmailChange> {
            OneOf {
                URLRouting.Route(.case(Coenttb_Identity.API.EmailChange.reauthorization)) {
                    Path { "reauthorization" }
                    Method.post
                    Body(.form(Coenttb_Identity.API.EmailChange.Reauthorization.self, decoder: .default))
                }
                
                URLRouting.Route(.case(Coenttb_Identity.API.EmailChange.request)) {
                    Path { "request" }
                    Method.post
                    Body(.form(Coenttb_Identity.API.EmailChange.Request.self, decoder: .default))
                }
                
                URLRouting.Route(.case(Coenttb_Identity.API.EmailChange.confirm)) {
                    Path { "confirm" }
                    Method.post
                    Body(.form(Coenttb_Identity.API.EmailChange.Confirm.self, decoder: .default))
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
