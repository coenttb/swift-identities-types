//
//  File.swift
//  coenttb-web
//
//  Deleted by Coen ten Thije Boonkkamp on 17/10/2024.
//

import CoenttbWeb
import MemberwiseInit
import MacroCodableKit

extension CoenttbIdentity.API {
    public enum Delete: Codable, Hashable, Sendable {
        case request(Delete.Request)
        case cancel(Delete.Cancel)
        
        @MemberwiseInit(.public)
        @Codable
        public struct Request: Hashable, Sendable {
            @CodingKey(.userId)
            @Init(default: "")
            public let userId: String
            
            @CodingKey(.reauthToken)
            @Init(default: "")
            public let reauthToken: String
        }
        
        @MemberwiseInit(.public)
        @Codable
        public struct Cancel: Hashable, Sendable {
            @CodingKey(.userId)
            @Init(default: "")
            public let userId: String
        }
    }
}

extension CoenttbIdentity.API.Delete {
    public struct Router: ParserPrinter, Sendable {
        
        public init(){}
        
        public var body: some URLRouting.Router<CoenttbIdentity.API.Delete> {
            OneOf {
                URLRouting.Route(.case(CoenttbIdentity.API.Delete.request)) {
                    Path { "request" }
                    Method.post
                    Body(.form(CoenttbIdentity.API.Delete.Request.self, decoder: .default))
                }
                
                URLRouting.Route(.case(CoenttbIdentity.API.Delete.cancel)) {
                    Path { "cancel" }
                    Method.post
                    Body(.form(CoenttbIdentity.API.Delete.Cancel.self, decoder: .default))
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
