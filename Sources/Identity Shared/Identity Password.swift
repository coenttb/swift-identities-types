//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import Coenttb_Web

public enum Password {}

extension Password {
    public enum Reset {}
    public enum Change {}
}

extension Password.Reset {
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
 
extension Identity_Shared.Password.Reset.Request {
    public init(
        email: EmailAddress
    ){
        self.email = email.rawValue
    }
}

extension Identity_Shared.Password.Reset.Request {
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}

        public var body: some URLRouting.Router<Identity_Shared.Password.Reset.Request> {
            Method.post
            Path.request
            Body(.form(Identity_Shared.Password.Reset.Request.self, decoder: .default))
        }
    }
}

extension Password.Reset {
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

extension Identity_Shared.Password.Reset.Confirm {
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}

        public var body: some URLRouting.Router<Identity_Shared.Password.Reset.Confirm> {
            Method.post
            Path.confirm
            Body(.form(Identity_Shared.Password.Reset.Confirm.self, decoder: .default))
        }
    }
}

extension Identity_Shared.Password.Change {
    public typealias Reauthorization = Identity.Reauthorization
}


 
extension Identity_Shared.Password.Change {
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

extension Identity_Shared.Password.Change.Request {
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}

        public var body: some URLRouting.Router<Identity_Shared.Password.Change.Request> {
            Method.post
            Path.request
            Body(.form(Identity_Shared.Password.Change.Request.self, decoder: .default))
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
