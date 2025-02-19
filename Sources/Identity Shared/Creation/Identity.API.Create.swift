//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

import SwiftWeb

extension Identity.API {
    public enum Create: Equatable, Sendable {
        case request(Identity.Creation.Request)
        case verify(Identity.Creation.Verify)
    }
}

extension Identity.API.Create {
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.API.Create> {
            OneOf {
                URLRouting.Route(.case(Identity.API.Create.request)) {
                    Identity.Creation.Request.Router()
                }
                URLRouting.Route(.case(Identity.API.Create.verify)) {
                    Identity.Creation.Verify.Router()
                }
            }
        }
    }
}
