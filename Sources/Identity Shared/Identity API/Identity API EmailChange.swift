//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

import Coenttb_Web

extension Identity.API {
    public enum EmailChange: Equatable, Sendable {
        case request(Identity.EmailChange.Request)
        case confirm(Identity.EmailChange.Confirm)
    }
}


extension Identity.API.EmailChange {
    public struct Router: ParserPrinter, Sendable {
        
        public init(){}
        
        public var body: some URLRouting.Router<Identity.API.EmailChange> {
            OneOf {
                URLRouting.Route(.case(Identity.API.EmailChange.request)) {
                    Identity.EmailChange.Request.Router()
                }
                
                URLRouting.Route(.case(Identity.API.EmailChange.confirm)) {
                    Identity.EmailChange.Confirm.Router()
                }
            }
        }
    }
}
