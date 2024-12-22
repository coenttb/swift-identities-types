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
    public enum EmailChange: Equatable, Sendable {
        case reauthorization(CoenttbIdentity.API.EmailChange.Reauthorization)
        case request(CoenttbIdentity.API.EmailChange.Request)
        case confirm(CoenttbIdentity.API.EmailChange.Confirm)
    }
}

extension CoenttbIdentity.API.EmailChange {
    @MemberwiseInit(.public)
    @Codable
    public struct Reauthorization: Hashable, Sendable {
        @CodingKey(.password)
        @Init(default: "")
        public let password: String
    }
}
 
extension CoenttbIdentity.API.EmailChange {
    @MemberwiseInit(.public)
    @Codable
    public struct Request: Hashable, Sendable {
        @CodingKey(.newEmail)
        @Init(default: "")
        public let newEmail: String
    }
}

extension CoenttbIdentity.API.EmailChange.Request {
    public init(
        newEmail: EmailAddress
    ){
        self.newEmail = newEmail.rawValue
    }
}
 
extension CoenttbIdentity.API.EmailChange {
    @MemberwiseInit(.public)
    @Codable
    public struct Confirm: Hashable, Sendable {
        @CodingKey(.token)
        @Init(default: "")
        public let token: String
        
        @CodingKey(.newEmail)
        @Init(default: "")
        public let newEmail: String
    }
}

extension CoenttbIdentity.API.EmailChange.Confirm {
    public init(
        token: String,
        newEmail: EmailAddress
    ){
        self.token = token
        self.newEmail = newEmail.rawValue
    }
}

extension CoenttbIdentity.API.EmailChange {
    public struct Router: ParserPrinter, Sendable {
        
        public init(){}
        
        public var body: some URLRouting.Router<CoenttbIdentity.API.EmailChange> {
            OneOf {
                URLRouting.Route(.case(CoenttbIdentity.API.EmailChange.reauthorization)) {
                    Path { "reauthorization" }
                    Method.post
                    Body(.form(CoenttbIdentity.API.EmailChange.Reauthorization.self, decoder: .default))
                }
                
                URLRouting.Route(.case(CoenttbIdentity.API.EmailChange.request)) {
                    Path { "request" }
                    Method.post
                    Body(.form(CoenttbIdentity.API.EmailChange.Request.self, decoder: .default))
                }
                
                URLRouting.Route(.case(CoenttbIdentity.API.EmailChange.confirm)) {
                    Path { "confirm" }
                    Method.post
                    Body(.form(CoenttbIdentity.API.EmailChange.Confirm.self, decoder: .default))
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
