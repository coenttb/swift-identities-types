//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 14/02/2025.
//

import Foundation
import Dependencies
import URLRouting

private enum IdentityConsumerAPIRouterKey: DependencyKey {
    static let liveValue: AnyParserPrinter<URLRequestData, Identity.Consumer.API> = {
        Identity.Consumer.API.Router().eraseToAnyParserPrinter()
    }()
    
    static let testValue: AnyParserPrinter<URLRequestData, Identity.Consumer.API> = liveValue
}

extension DependencyValues {
    public var identityConsumerApiRouter: AnyParserPrinter<URLRequestData, Identity.Consumer.API> {
        get { self[IdentityConsumerAPIRouterKey.self] }
        set { self[IdentityConsumerAPIRouterKey.self] = newValue }
    }
}
