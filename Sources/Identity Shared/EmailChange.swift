//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import Coenttb_Web

public enum EmailChange {}

extension EmailChange {
    public typealias Reauthorization = Identity_Shared.Reauthorization
}
 
extension EmailChange {
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

extension EmailChange.Request {
    public init(
        newEmail: EmailAddress
    ){
        self.newEmail = newEmail.rawValue
    }
}
 
extension Identity_Shared.EmailChange.Request {
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}

        public var body: some URLRouting.Router<Identity_Shared.EmailChange.Request> {
            Method.post
            Path.request
            Body(.form(Identity_Shared.EmailChange.Request.self, decoder: .default))
        }
    }
}

extension EmailChange {
    public struct Confirm: Codable, Hashable, Sendable {
        public let token: String
        
        public init(
            token: String = ""
        ) {
            self.token = token
        }
        
        public enum CodingKeys: String, CodingKey {
            case token
        }
    }
}

extension Identity_Shared.EmailChange.Confirm {
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}

        public var body: some URLRouting.Router<Identity_Shared.EmailChange.Confirm> {
            Method.post
            Path.confirm
            Body(.form(Identity_Shared.EmailChange.Confirm.self, decoder: .default))
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

extension EmailChange.Request {
    public enum Error: Swift.Error, Sendable {
        case unauthorized
        case emailIsNil
    }
}
