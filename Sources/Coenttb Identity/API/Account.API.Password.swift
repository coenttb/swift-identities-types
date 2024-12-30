//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

import Coenttb_Web

extension Coenttb_Identity.API {
    public enum Password: Equatable, Sendable {
        case reset(Coenttb_Identity.API.Password.Reset)
        case change(Coenttb_Identity.API.Password.Change)
    }
}

extension Coenttb_Identity.API.Password {
    public enum Reset: Equatable, Sendable {
        case request(Coenttb_Identity.API.Password.Reset.Request)
        case confirm(Coenttb_Identity.API.Password.Reset.Confirm)
    }
}

extension Coenttb_Identity.API.Password.Reset {
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
 
extension Coenttb_Identity.API.Password.Reset.Request {
    public init(
        email: EmailAddress
    ){
        self.email = email.rawValue
    }
}

extension Coenttb_Identity.API.Password.Reset {
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

extension Coenttb_Identity.API.Password {
    public enum Change: Equatable, Sendable {
        case reauthorization(Coenttb_Identity.API.Password.Change.Reauthorization)
        case request(change: Coenttb_Identity.API.Password.Change.Request)
    }
}

extension Coenttb_Identity.API.Password.Change {
    public struct Reauthorization: Codable, Hashable, Sendable {
        public let password: String
        
        public init(
            password: String = ""
        ) {
            self.password = password
        }
        
        public enum CodingKeys: String, CodingKey {
            case password
        }
    }
    
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

extension Coenttb_Identity.API.Password {
    public struct Router: ParserPrinter, Sendable {
        
        public init(){}
        
        public var body: some URLRouting.Router<Coenttb_Identity.API.Password> {
            OneOf {
                URLRouting.Route(.case(Coenttb_Identity.API.Password.reset)) {
                    Path { "reset" }
                    OneOf {
                        URLRouting.Route(.case(Coenttb_Identity.API.Password.Reset.request)) {
                            Path { "request" }
                            Method.post
                            Body(.form(Coenttb_Identity.API.Password.Reset.Request.self, decoder: .default))
                        }
                        
                        URLRouting.Route(.case(Coenttb_Identity.API.Password.Reset.confirm)) {
                            Method.post
                            Path { "confirm" }
                            Body(.form(Coenttb_Identity.API.Password.Reset.Confirm.self, decoder: .default))
                        }
                    }
                }
                
                URLRouting.Route(.case(Coenttb_Identity.API.Password.change)) {
                    Path { "change" }
                    OneOf {
                        URLRouting.Route(.case(Coenttb_Identity.API.Password.Change.reauthorization)) {
                            Method.post
                            Path { "reauthorization" }
                            Body(.form(Coenttb_Identity.API.Password.Change.Reauthorization.self, decoder: .default))
                        }
                        
                        URLRouting.Route(.case(Coenttb_Identity.API.Password.Change.request)) {
                            Method.post
                            Path { "request" }
                            Body(.form(Coenttb_Identity.API.Password.Change.Request.self, decoder: .default))
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
