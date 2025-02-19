//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import BearerAuth
import Coenttb_Web
import Foundation
import URLRouting

extension Identity.API {
    public enum Authenticate: Equatable, Sendable {
        case credentials(Identity.Authentication.Credentials)
        case token(Identity.API.Authenticate.Token)
        case apiKey(BearerAuth)
    }
}

extension Identity.API.Authenticate {
    public enum Token: Codable, Hashable, Sendable {
        case access(BearerAuth)
        case refresh(BearerAuth)
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

                URLRouting.Route(.case(Identity.API.Authenticate.token)) {
                    Method.post
                    OneOf {
                        URLRouting.Route(.case(Identity.API.Authenticate.Token.access)) {
                            Path.access
                            BearerAuth.Router()
                        }

                        URLRouting.Route(.case(Identity.API.Authenticate.Token.refresh)) {
                            Path.refresh
                            BearerAuth.Router()
                        }
                    }
                }

                URLRouting.Route(.case(Identity.API.Authenticate.apiKey)) {
                    Path.apiKey
                    BearerAuth.Router()
                }
            }
        }
    }
}
