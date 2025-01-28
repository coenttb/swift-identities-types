//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2024.
//

import Coenttb_Web

public enum API: Equatable, Sendable {
    case create(Coenttb_Identity.API.Create)
    case login(Coenttb_Identity.API.Login)
    case currentUser
    case logout
    case update(Coenttb_Identity.API.Update)
    case delete(Coenttb_Identity.API.Delete)
    case password(Coenttb_Identity.API.Password)
    case emailChange(Coenttb_Identity.API.EmailChange)
}

extension Coenttb_Identity.API {
    public struct Router: ParserPrinter, Sendable {
        
        public init(){}
        
        public var body: some URLRouting.Router<Coenttb_Identity.API> {
            OneOf {
                
                URLRouting.Route(.case(Coenttb_Identity.API.create)) {
                    Path { "create" }
                    Coenttb_Identity.API.Create.Router()
                }
                
                URLRouting.Route(.case(Coenttb_Identity.API.update)) {
                    Method.post
                    Path { "update" }
                    Body(.form(Coenttb_Identity.API.Update.self, decoder: .default))
                }
                
                URLRouting.Route(.case(Coenttb_Identity.API.delete)) {
                    Path { "delete" }
                    Coenttb_Identity.API.Delete.Router()
                }
                
                URLRouting.Route(.case(Coenttb_Identity.API.login)) {
                    Method.post
                    Path { "login" }
                    Body(.form(Coenttb_Identity.API.Login.self, decoder: .default))
                }
                
                URLRouting.Route(.case(Coenttb_Identity.API.currentUser)) {
                    Method.get
                    Path { "current" }
                }
                
                URLRouting.Route(.case(Coenttb_Identity.API.logout)) {
                    Method.post
                    Path { "logout" }
                }
                
                URLRouting.Route(.case(Coenttb_Identity.API.password)) {
                    Path { "password" }
                    Coenttb_Identity.API.Password.Router()
                }
                
                URLRouting.Route(.case(Coenttb_Identity.API.emailChange)) {
                    Path { "email-change" }
                    Coenttb_Identity.API.EmailChange.Router()
                }
            }
        }
    }
}

extension Coenttb_Identity.API {
    public struct Search: Codable, Hashable, Sendable {
        public let value: String
        
        public init(
            value: String = ""
        ) {
            self.value = value
        }
        
        public enum CodingKeys: String, CodingKey {
            case value
        }
    }
}

extension Coenttb_Identity.API {
    public struct Update: Codable, Hashable, Sendable {
        public let name: String?
        
        public init(
            name: String? = nil
        ) {
            self.name = name
        }
        
        public enum CodingKeys: String, CodingKey {
            case name
        }
    }
}

extension Coenttb_Identity.API {
    public struct Login: Codable, Hashable, Sendable {
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

extension Coenttb_Identity.API.Login {
    public init(
        email: EmailAddress,
        password: String
    ){
        self.email = email.rawValue
        self.password = password
    }
}

extension Coenttb_Identity.API {
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

extension Coenttb_Identity.API.Verify {
    public init(
        email: EmailAddress,
        token: String
    ){
        self.email = email.rawValue
        self.token = token
    }
}

extension UrlFormDecoder {
    fileprivate static var `default`: UrlFormDecoder {
        let decoder = UrlFormDecoder()
        decoder.parsingStrategy = .bracketsWithIndices
        return decoder
    }
}


