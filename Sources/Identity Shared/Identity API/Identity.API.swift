//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2024.
//

import Coenttb_Web

extension Identity {
    public enum API: Equatable, Sendable {
        case authenticate(Identity.API.Authenticate)
        case create(Identity.API.Create)
        case delete(Identity.API.Delete)
        case logout
        case reauthorize(Identity.API.Reauthorize)
        case email(Identity.API.Email)
        case password(Identity.API.Password)
    }
}

extension Identity.API {
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.API> {
            OneOf {

                URLRouting.Route(.case(Identity.API.create)) {
                    Path.create
                    Identity.API.Create.Router()
                }

                URLRouting.Route(.case(Identity.API.delete)) {
                    Path.delete
                    Identity.API.Delete.Router()
                }

                URLRouting.Route(.case(Identity.API.authenticate)) {
                    Path.authenticate
                    Identity.API.Authenticate.Router()
                }

                URLRouting.Route(.case(Identity.API.logout)) {
                    Path.logout
                    Method.post
                }

                URLRouting.Route(.case(Identity.API.reauthorize)) {
                    Method.post
                    Path.reauthorize
                    Body(.form(Identity.API.Reauthorize.self, decoder: .default))
                }

                URLRouting.Route(.case(Identity.API.password)) {
                    Path.password
                    Identity.API.Password.Router()
                }

                URLRouting.Route(.case(Identity.API.email)) {
                    Path.email
                    Identity.API.Email.Router()
                }
            }
        }
    }
}

extension URLRequestData: @retroactive @unchecked Sendable {}
extension AnyParserPrinter: @unchecked @retroactive Sendable where Input: Sendable, Output: Sendable {}

extension Identity.API.Router: TestDependencyKey {
    public static let testValue: AnyParserPrinter<URLRequestData, Identity.API> = Identity.API.Router().eraseToAnyParserPrinter()
}
