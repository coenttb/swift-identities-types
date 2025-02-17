//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 14/02/2025.
//

import Foundation
import Dependencies
import URLRouting
import Identity_Provider

private enum IdentityProviderAPIRouterKey: DependencyKey {
    static let liveValue: AnyParserPrinter<URLRequestData, Identity.API> = {
        @Dependency(Identity.Provider.Configuration.self) var provider
        return Identity.API.Router().baseURL(provider.baseURL.absoluteString).eraseToAnyParserPrinter()
    }()
    
    static let testValue: AnyParserPrinter<URLRequestData, Identity.API> = liveValue
}

extension DependencyValues {
    public var identityProviderApiRouter: AnyParserPrinter<URLRequestData, Identity.API> {
        get { self[IdentityProviderAPIRouterKey.self] }
        set { self[IdentityProviderAPIRouterKey.self] = newValue }
    }
}
