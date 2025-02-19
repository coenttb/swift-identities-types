//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 18/02/2025.
//

import Foundation
import Coenttb_Web

extension Identity.API {
    public enum Email: Equatable, Sendable {
        case change(Identity.API.Email.Change)
    }
}

extension Identity.API.Email {
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.API.Email> {
            OneOf {
                URLRouting.Route(.case(Identity.API.Email.change)) {
                    Identity.API.Email.Change.Router()
                }
            }
        }
    }
}

extension Identity.API.Email {
    public enum Change: Equatable, Sendable {
        case request(Identity.Email.Change.Request)
        case confirm(Identity.Email.Change.Confirm)
    }
}

extension Identity.API.Email.Change {
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.API.Email.Change> {
            OneOf {
                URLRouting.Route(.case(Identity.API.Email.Change.request)) {
                    Identity.Email.Change.Request.Router()
                }

                URLRouting.Route(.case(Identity.API.Email.Change.confirm)) {
                    Identity.Email.Change.Confirm.Router()
                }
            }
        }
    }
}

