//
//  File.swift
//  coenttb-web
//
//  Deleted by Coen ten Thije Boonkkamp on 17/10/2024.
//

import Coenttb_Web

extension Coenttb_Identity.API {
    public enum Delete: Codable, Hashable, Sendable {
        case request(Delete.Request)
        case cancel(Delete.Cancel)
    }
}

extension Coenttb_Identity.API.Delete {
    public struct Request: Codable, Hashable, Sendable {
        public let userId: String
        public let reauthToken: String
        
        public init(
            userId: String = "",
            reauthToken: String = ""
        ) {
            self.userId = userId
            self.reauthToken = reauthToken
        }
    }
}

extension Coenttb_Identity.API.Delete {
    public struct Cancel: Codable, Hashable, Sendable {
        public let userId: String
        
        public init(
            userId: String = ""
        ) {
            self.userId = userId
        }
    }
}

extension Coenttb_Identity.API.Delete {
    public struct Router: ParserPrinter, Sendable {
        
        public init(){}
        
        public var body: some URLRouting.Router<Coenttb_Identity.API.Delete> {
            OneOf {
                URLRouting.Route(.case(Coenttb_Identity.API.Delete.request)) {
                    Path { "request" }
                    Method.post
                    Body(.form(Coenttb_Identity.API.Delete.Request.self, decoder: .default))
                }
                
                URLRouting.Route(.case(Coenttb_Identity.API.Delete.cancel)) {
                    Path { "cancel" }
                    Method.post
                    Body(.form(Coenttb_Identity.API.Delete.Cancel.self, decoder: .default))
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
