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

private enum IdentityConsumerRouteRouterConsumer: TestDependencyKey {
    static let testValue: AnyParserPrinter<URLRequestData, Identity.Consumer.Route> = liveValue
    static let liveValue: AnyParserPrinter<URLRequestData, Identity.Consumer.Route> = Identity.Consumer.Route.Router().eraseToAnyParserPrinter()
}

extension DependencyValues {
    public var identityConsumerRouter: AnyParserPrinter<URLRequestData, Identity.Consumer.Route> {
        get { self[IdentityConsumerRouteRouterConsumer.self] }
        set { self[IdentityConsumerRouteRouterConsumer.self] = newValue }
    }
}

private enum IdentityConsumerRouteRouterProvider: TestDependencyKey {
    static let testValue: AnyParserPrinter<URLRequestData, Identity.Consumer.Route> = liveValue
    static let liveValue: AnyParserPrinter<URLRequestData, Identity.Consumer.Route> = Identity.Consumer.Route.Router().eraseToAnyParserPrinter()
}

extension DependencyValues {
    public var identityProviderRouter: AnyParserPrinter<URLRequestData, Identity.Consumer.Route> {
        get { self[IdentityConsumerRouteRouterProvider.self] }
        set { self[IdentityConsumerRouteRouterProvider.self] = newValue }
    }
}



//extension Identity.Consumer.Route.Router: TestDependencyKey {
//    public static let testValue: AnyParserPrinter<URLRequestData, Identity.Consumer.Route> = Identity.Consumer.Route.Router().eraseToAnyParserPrinter()
//}
