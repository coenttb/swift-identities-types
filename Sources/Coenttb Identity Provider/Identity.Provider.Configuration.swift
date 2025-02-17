//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 17/02/2025.
//

import Foundation
import Dependencies
import Identity_Shared
import Identity_Provider
import URLRouting
import Coenttb_Identity_Shared

extension Identity.Provider {
    public struct Configuration:  Sendable {
        public var provider: Identity.Provider.Configuration.Provider
        
        public init(provider: Identity.Provider.Configuration.Provider) {
            self.provider = provider
        }
    }
}

extension Identity.Provider.Configuration {
    public struct Provider: Sendable {
        public var baseURL: URL
        public var domain: String?
        public var issuer: String?
        public var cookies: Identity.CookiesConfiguration
        public var router: AnyParserPrinter<URLRequestData, Identity.API>
        public var client: Identity.Provider.Client
        
        public init(
            baseURL: URL,
            domain: String?,
            issuer: String?,
            cookies: Identity.CookiesConfiguration,
            router: AnyParserPrinter<URLRequestData, Identity.API>,
            client: Identity.Provider.Client
            
        ) {
            self.baseURL = baseURL
            self.domain = domain
            self.issuer = issuer
            self.cookies = cookies
            self.router = router.baseURL(baseURL.absoluteString).eraseToAnyParserPrinter()
            self.client = client
        }
    }
}

extension Identity.Provider.Configuration: TestDependencyKey {
    public static let testValue: Self = .init(provider: .testValue)
}

extension DependencyValues {
    public var identity: Identity.Provider.Configuration {
        get { self[Identity.Provider.Configuration.self] }
        set { self[Identity.Provider.Configuration.self] = newValue }
    }
}

extension Identity.Provider.Configuration.Provider: TestDependencyKey {
    public static let testValue: Self = .init(
        baseURL: .init(string: "")!,
        domain: nil,
        issuer: nil,
        cookies: .testValue,
        router: Identity.API.Router().eraseToAnyParserPrinter(),
        client: .testValue
    )
}



import Vapor
extension HTTPCookies.Value {
    
    package static func accessToken(
        token: JWT.Token
    ) -> Self {
        @Dependency(\.identity.provider.cookies.accessToken) var config

        return withDependencies {
            $0.identity.provider.cookies.accessToken.sameSitePolicy = .lax
        } operation: {
            return HTTPCookies.Value(
                token: token.value
            )
        }
    }
    
    package static func refreshToken(
        token: JWT.Token
    ) -> Self {
        @Dependency(\.identity.provider.cookies.refreshToken) var config
        @Dependency(\.identity.provider.router) var identityProviderRouter

        return withDependencies {
            $0.identity.provider.cookies.refreshToken.path = identityProviderRouter.url(for: .authenticate(.token(.refresh(.init(token: token.value))))).relativePath
        } operation: {
            return .init(
                token: token.value
            )
        }
    }
}
