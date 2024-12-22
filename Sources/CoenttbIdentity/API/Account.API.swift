//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2024.
//

import Dependencies
import EmailAddress
import Foundation
import Languages
import MemberwiseInit
import URLRouting
import MacroCodableKit
import UrlFormCoding
import CoenttbWebTranslations

public enum API: Equatable, Sendable {
    case create(CoenttbIdentity.API.Create)
    case login(CoenttbIdentity.API.Login)
    case logout
    case update(CoenttbIdentity.API.Update)
    case delete(CoenttbIdentity.API.Delete)
    case password(CoenttbIdentity.API.Password)
    case emailChange(CoenttbIdentity.API.EmailChange)
}

extension CoenttbIdentity.API {
    public struct Router: ParserPrinter, Sendable {
        
        public init(){}
        
        public var body: some URLRouting.Router<CoenttbIdentity.API> {
            OneOf {
                
                URLRouting.Route(.case(CoenttbIdentity.API.create)) {
                    Path { "create" }
                    CoenttbIdentity.API.Create.Router()
                }
                
                URLRouting.Route(.case(CoenttbIdentity.API.update)) {
                    Method.post
                    Path { "update" }
                    Body(.form(CoenttbIdentity.API.Update.self, decoder: .default))
                }
                
                URLRouting.Route(.case(CoenttbIdentity.API.delete)) {
                    Path { "delete" }
                    CoenttbIdentity.API.Delete.Router()
                }
                
                URLRouting.Route(.case(CoenttbIdentity.API.login)) {
                    Method.post
                    Path { "login" }
                    Body(.form(CoenttbIdentity.API.Login.self, decoder: .default))
                }
                
                URLRouting.Route(.case(CoenttbIdentity.API.logout)) {
                    Method.post
                    Path { "logout" }
                }
                
                URLRouting.Route(.case(CoenttbIdentity.API.password)) {
                    Path { "password" }
                    CoenttbIdentity.API.Password.Router()
                }
                
                URLRouting.Route(.case(CoenttbIdentity.API.emailChange)) {
                    Path { "email-change" }
                    CoenttbIdentity.API.EmailChange.Router()
                }
            }
        }
    }
}

extension CoenttbIdentity.API {
    @MemberwiseInit(.public)
    @Codable
    public struct Search: Hashable, Sendable {
        @CodingKey("value")
        @Init(default: "")
        public let value: String
    }
}

extension CoenttbIdentity.API {
    @MemberwiseInit(.public)
    @Codable
    public struct Update: Hashable, Sendable {
        @CodingKey("name")
        @Init(default: "")
        public let name: String?
    }
}



extension CoenttbIdentity.API {
    @MemberwiseInit(.public)
    @Codable
    public struct Login: Hashable, Sendable {
        @CodingKey(.email)
        @Init(default: "")
        public let email: String
        
        @CodingKey(.password)
        @Init(default: "")
        public let password: String
    }
}

extension CoenttbIdentity.API {
    @MemberwiseInit(.public)
    @Codable
    public struct Verify: Hashable, Sendable {
        @CodingKey(.token)
        @Init(default: "")
        public let token: String
        
        @CodingKey(.email)
        @Init(default: "")
        public let email: String
    }
}

extension UrlFormDecoder {
    fileprivate static var `default`: UrlFormDecoder {
        let decoder = UrlFormDecoder()
        decoder.parsingStrategy = .bracketsWithIndices
        return decoder
    }
}


