//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import Foundation
import Identity_Shared
import Coenttb_Web
import Dependencies


extension Identity.Consumer {
    public enum Route: Equatable, Sendable {
        case api(Identity.Consumer.API)
        case view(Identity.Consumer.View)
    }
}

extension Identity.Consumer.Route {
    public struct Router: ParserPrinter, Sendable {
        
        public init(){}
        
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

extension Identity.Consumer.Route.Router: DependencyKey {
    public static let liveValue: Self = .init()
    public static let testValue: Self = liveValue
}
