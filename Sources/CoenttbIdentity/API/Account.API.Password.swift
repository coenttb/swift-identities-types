//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

import CoenttbWeb
import MemberwiseInit
import MacroCodableKit

extension CoenttbIdentity.API {
    public enum Password: Equatable, Sendable {
        case reset(CoenttbIdentity.API.Password.Reset)
        case change(CoenttbIdentity.API.Password.Change)
    }
}

extension CoenttbIdentity.API.Password {
    public enum Reset: Equatable, Sendable {
        case request(CoenttbIdentity.API.Password.Reset.Request)
        case confirm(CoenttbIdentity.API.Password.Reset.Confirm)
    }
}

extension CoenttbIdentity.API.Password.Reset {
    @MemberwiseInit(.public)
    @Codable
    public struct Request: Hashable, Sendable {
        @CodingKey(.email)
        @Init(default: "")
        public let email: String
    }
}
 
extension CoenttbIdentity.API.Password.Reset.Request {
    public init(
        email: EmailAddress
    ){
        self.email = email.rawValue
    }
}

extension CoenttbIdentity.API.Password.Reset {
    @MemberwiseInit(.public)
    @Codable
    public struct Confirm: Hashable, Sendable {
        @CodingKey(.token)
        @Init(default: "")
        public let token: String
        
        @CodingKey(.newPassword)
        @Init(default: "")
        public let newPassword: String
    }
}

extension CoenttbIdentity.API.Password {
    public enum Change: Equatable, Sendable {
        case reauthorization(CoenttbIdentity.API.Password.Change.Reauthorization)
        case request(change: CoenttbIdentity.API.Password.Change.Request)
    }
}

extension CoenttbIdentity.API.Password.Change {
    @MemberwiseInit(.public)
    @Codable
    public struct Reauthorization: Hashable, Sendable {
        @CodingKey(.currentPassword)
        @Init(default: "")
        public let password: String
    }
    
    @MemberwiseInit(.public)
    @Codable
    public struct Request: Hashable, Sendable {
        @CodingKey(.currentPassword)
        @Init(default: "")
        public let currentPassword: String
        
        @CodingKey(.newPassword)
        @Init(default: "")
        public let newPassword: String
    }
}

extension CoenttbIdentity.API.Password {
    public struct Router: ParserPrinter, Sendable {
        
        public init(){}
        
        public var body: some URLRouting.Router<CoenttbIdentity.API.Password> {
            OneOf {
                URLRouting.Route(.case(CoenttbIdentity.API.Password.reset)) {
                    Path { "reset" }
                    OneOf {
                        URLRouting.Route(.case(CoenttbIdentity.API.Password.Reset.request)) {
                            Path { "request" }
                            Method.post
                            Body(.form(CoenttbIdentity.API.Password.Reset.Request.self, decoder: .default))
                        }
                        
                        URLRouting.Route(.case(CoenttbIdentity.API.Password.Reset.confirm)) {
                            Method.post
                            Path { "confirm" }
                            Body(.form(CoenttbIdentity.API.Password.Reset.Confirm.self, decoder: .default))
                        }
                    }
                }
                
                URLRouting.Route(.case(CoenttbIdentity.API.Password.change)) {
                    Path { "change" }
                    OneOf {
                        URLRouting.Route(.case(CoenttbIdentity.API.Password.Change.reauthorization)) {
                            Method.post
                            Path { "reauthorization" }
                            Body(.form(CoenttbIdentity.API.Password.Change.Reauthorization.self, decoder: .default))
                        }
                        
                        URLRouting.Route(.case(CoenttbIdentity.API.Password.Change.request)) {
                            Method.post
                            Path { "request" }
                            Body(.form(CoenttbIdentity.API.Password.Change.Request.self, decoder: .default))
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
