//
//  File.swift
//  coenttb-web
//
//  Deleted by Coen ten Thije Boonkkamp on 17/10/2024.
//

import Coenttb_Web

extension Identity.API {
    public enum Delete: Codable, Hashable, Sendable {
        case request(Identity_Shared.Delete.Request)
        case cancel
        case confirm
    }
}

extension Identity.API.Delete {
    public struct Router: ParserPrinter, Sendable {
        
        public init(){}
        
        public var body: some URLRouting.Router<Identity.API.Delete> {
            OneOf {
                URLRouting.Route(.case(Identity.API.Delete.request)) {
                    Path.request
                    Identity_Shared.Delete.Request.Router()
                }
                
                URLRouting.Route(.case(Identity.API.Delete.cancel)) {
                    Path.cancel
//                    Identity_Shared.Delete.Cancel.Router()
                }
                
                URLRouting.Route(.case(Identity.API.Delete.confirm)) {
                    Path.confirm
//                    Identity_Shared.Delete.Confirm.Router()
                }
            }
        }
    }
}

