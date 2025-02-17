//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

import Coenttb_Web

extension Identity.API {
    public enum Password: Equatable, Sendable {
        case reset(Identity.API.Password.Reset)
        case change(Identity.API.Password.Change)
    }
}

extension Identity.API.Password {
    public enum Reset: Equatable, Sendable {
        case request(Identity.Password.Reset.Request)
        case confirm(Identity.Password.Reset.Confirm)
    }
}

extension Identity.API.Password {
    public enum Change: Equatable, Sendable {
//        case reauthorization(Identity.Password.Change.Reauthorization)
        case request(change: Identity.Password.Change.Request)
    }
}

extension Identity.API.Password {
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.API.Password> {
            OneOf {
                URLRouting.Route(.case(Identity.API.Password.reset)) {
                    Path.reset
                    OneOf {
                        URLRouting.Route(.case(Identity.API.Password.Reset.request)) {
                            Identity.Password.Reset.Request.Router()
                        }

                        URLRouting.Route(.case(Identity.API.Password.Reset.confirm)) {
                            Identity.Password.Reset.Confirm.Router()
                        }
                    }
                }

                URLRouting.Route(.case(Identity.API.Password.change)) {
                    Path.change
                    OneOf {
                        URLRouting.Route(.case(Identity.API.Password.Change.request)) {
                            Identity.Password.Change.Request.Router()
                        }
                    }
                }
            }
        }
    }
}
