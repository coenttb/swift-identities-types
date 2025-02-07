//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import Foundation
import BearerAuth
import Coenttb_Web

extension Identity.API {
    public enum Authenticate: Equatable, Sendable {
        case credentials(Identity.Authentication.Credentials)
        case bearer(BearerAuth)
    }
}

extension Identity.API.Authenticate {
    public struct Router: ParserPrinter, Sendable {
        
        public init() {}

        public var body: some URLRouting.Router<Identity.API.Authenticate> {
            OneOf {
                URLRouting.Route(.case(Identity.API.Authenticate.credentials)) {
                    Method.post
                    Body(.form(Identity.Authentication.Credentials.self, decoder: .default))
                }
                
                URLRouting.Route(.case(Identity.API.Authenticate.bearer)) {
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
