//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import Coenttb_Web
import EmailAddress

public struct Login: Codable, Hashable, Sendable {
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

extension Login {
    public init(
        email: EmailAddress,
        password: String
    ){
        self.email = email.rawValue
        self.password = password
    }
}

extension Identity_Shared.Login {
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}

        public var body: some URLRouting.Router<Identity_Shared.Login> {
            Method.post

            Body(.form(Identity_Shared.Login.self, decoder: .default))
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
