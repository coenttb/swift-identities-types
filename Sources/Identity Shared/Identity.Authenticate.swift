//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import Coenttb_Web
import EmailAddress
import Coenttb_Authentication
import BearerAuth

extension Identity {
    public enum Authenticate: Equatable, Sendable {
        case credentials(Credentials)
        case bearer(BearerAuth)
    }
}

extension Identity.Authenticate {
    public struct Credentials: Codable, Hashable, Sendable {
        public let email: String
        public let password: String
    
        public init(
            email: String = "",
            password: String = ""
        ) {
            self.email = email
            self.password = password
        }
    
        public enum CodingKeys: String, CodingKey {
            case email
            case password
        }
    }
}

extension Identity.Authenticate.Credentials {
    public init(
        email: EmailAddress,
        password: String
    ){
        self = .init(email: email.rawValue, password: password)
    }
}

extension Identity.Authenticate {
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}

        public var body: some URLRouting.Router<Identity.Authenticate> {
            OneOf {
                URLRouting.Route(.case(Identity.Authenticate.credentials)) {
                    Method.post
                    Body(.form(Identity.Authenticate.Credentials.self, decoder: .default))
                }
                
                URLRouting.Route(.case(Identity.Authenticate.bearer)) {
                    Method.post
                    BearerAuth.Router()
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
