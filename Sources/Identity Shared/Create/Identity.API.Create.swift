//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

import Coenttb_Web

extension Identity.API {
    public enum Create: Equatable, Sendable {
        case request(Identity.Create.Request)
        case verify(Identity.Create.Verify)
    }
}

extension Identity.API.Create {
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.API.Create> {
            OneOf {
                URLRouting.Route(.case(Identity.API.Create.request)) {
                    Identity.Create.Request.Router()
                }
                URLRouting.Route(.case(Identity.API.Create.verify)) {
                    Identity.Create.Verify.Router()
                }
            }
        }
    }
}
