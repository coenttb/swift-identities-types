//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

import Coenttb_Web

extension Identity.API {
    public enum Create: Equatable, Sendable {
        case request(Identity_Shared.Create.Request)
        case verify(Identity_Shared.Create.Verify)
    }
}

extension Identity.API.Create {
    public struct Router: ParserPrinter, Sendable {
        
        public init(){}
        
        public var body: some URLRouting.Router<Identity.API.Create> {
            OneOf {
                URLRouting.Route(.case(Identity.API.Create.request)) {
                    Identity_Shared.Create.Request.Router()
                }
                URLRouting.Route(.case(Identity.API.Create.verify)) {
                    Identity_Shared.Create.Verify.Router()
                }
            }
        }
    }
}
