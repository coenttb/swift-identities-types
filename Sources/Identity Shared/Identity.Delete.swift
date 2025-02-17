//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import Coenttb_Web

extension Identity {
    public enum Delete {}
}

extension Identity.Delete {
    public struct Request: Codable, Hashable, Sendable {
//        public let userId: String
        public let reauthToken: String

        public init(
//            userId: String = "",
            reauthToken: String = ""
        ) {
//            self.userId = userId
            self.reauthToken = reauthToken
        }

        public enum CodingKeys: String, CodingKey {
//            case userId
            case reauthToken
        }
    }
}

extension Identity.Delete.Request {
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.Delete.Request> {
            Method.post
            Body(.form(Identity.Delete.Request.self, decoder: .default))
        }
    }
}

//
// extension IdentityDelete {
//    public struct Cancel: Codable, Hashable, Sendable {
//        public let userId: String
//        
//        public init(
//            userId: String = ""
//        ) {
//            self.userId = userId
//        }
//    }
// }

// extension Identity.Delete.Cancel {
//    public struct Router: ParserPrinter, Sendable {
//        
//        public init() {}
//
//        public var body: some URLRouting.Router<Identity.Delete.Cancel> {
//            Method.post
//            Body(.form(Identity.Delete.Cancel.self, decoder: .default))
//        }
//    }
// }
//
// extension IdentityDelete {
//    public struct Confirm: Codable, Hashable, Sendable {
//        public let userId: String
//        
//        public init(
//            userId: String = ""
//        ) {
//            self.userId = userId
//        }
//    }
// }
//
// extension Identity.Delete.Confirm {
//    public struct Router: ParserPrinter, Sendable {
//        
//        public init() {}
//
//        public var body: some URLRouting.Router<Identity.Delete.Confirm> {
//            Method.post
//            Body(.form(Identity.Delete.Confirm.self, decoder: .default))
//        }
//    }
// }

extension UrlFormDecoder {
    fileprivate static var `default`: UrlFormDecoder {
        let decoder = UrlFormDecoder()
        decoder.parsingStrategy = .bracketsWithIndices
        return decoder
    }
}
