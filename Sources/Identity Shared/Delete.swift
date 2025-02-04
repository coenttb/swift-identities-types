//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import Coenttb_Web

public enum Delete {}

extension Delete {
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

extension Identity_Shared.Delete.Request {
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}

        public var body: some URLRouting.Router<Identity_Shared.Delete.Request> {
            Method.post
            Body(.form(Identity_Shared.Delete.Request.self, decoder: .default))
        }
    }
}

//
//extension Delete {
//    public struct Cancel: Codable, Hashable, Sendable {
//        public let userId: String
//        
//        public init(
//            userId: String = ""
//        ) {
//            self.userId = userId
//        }
//    }
//}

//extension Identity_Shared.Delete.Cancel {
//    public struct Router: ParserPrinter, Sendable {
//        
//        public init() {}
//
//        public var body: some URLRouting.Router<Identity_Shared.Delete.Cancel> {
//            Method.post
//            Body(.form(Identity_Shared.Delete.Cancel.self, decoder: .default))
//        }
//    }
//}
//
//extension Delete {
//    public struct Confirm: Codable, Hashable, Sendable {
//        public let userId: String
//        
//        public init(
//            userId: String = ""
//        ) {
//            self.userId = userId
//        }
//    }
//}
//
//extension Identity_Shared.Delete.Confirm {
//    public struct Router: ParserPrinter, Sendable {
//        
//        public init() {}
//
//        public var body: some URLRouting.Router<Identity_Shared.Delete.Confirm> {
//            Method.post
//            Body(.form(Identity_Shared.Delete.Confirm.self, decoder: .default))
//        }
//    }
//}

extension UrlFormDecoder {
    fileprivate static var `default`: UrlFormDecoder {
        let decoder = UrlFormDecoder()
        decoder.parsingStrategy = .bracketsWithIndices
        return decoder
    }
}
