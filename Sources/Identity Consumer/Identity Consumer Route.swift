//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import Coenttb_Web
import Dependencies
import Foundation
import Identity_Shared

extension Identity.Consumer {
    public enum Route: Equatable, Sendable {
        case api(Identity.Consumer.API)
        case view(Identity.Consumer.View)
    }
}

extension Identity.Consumer.Route {
    public struct Router: ParserPrinter, Sendable {

        public init() {}

        public var body: some URLRouting.Router<Identity.Consumer.Route> {
            OneOf {

                URLRouting.Route(.case(Identity.Consumer.Route.api)) {
                    Path.api
                    Identity.API.Router()
                }

                URLRouting.Route(.case(Identity.Consumer.Route.view)) {
                    Identity.Consumer.View.Router()
                }
            }
        }
    }
}

extension Identity.Consumer.Route.Router: TestDependencyKey {
    public static let testValue: AnyParserPrinter<URLRequestData, Identity.Consumer.Route> = Identity.Consumer.Route.Router().eraseToAnyParserPrinter()
}
