//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 17/02/2025.
//

import Foundation
import Dependencies
import Identities
import Identities
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
        public var cookies: Identity.CookiesConfiguration = .live
        public var router: AnyParserPrinter<URLRequestData, Identity.API>
        public var client: Identity.Provider.Client
        
        public init(
            baseURL: URL,
            domain: String?,
            issuer: String?,
            cookies: Identity.CookiesConfiguration = .live,
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

extension Identity.CookiesConfiguration {
    static public let live: Identity.CookiesConfiguration = .init(
        accessToken: .init(
            expires: 60 * 15,
            maxAge: 60 * 15,
            domain: nil,
            isSecure: true,
            isHTTPOnly: true,
            sameSitePolicy: .lax
        ),
        refreshToken: .init(
            expires: 60 * 60 * 24 * 30,
            maxAge: 60 * 60 * 24 * 30,
            domain: nil,
            path: nil,
            isSecure: true,
            isHTTPOnly: true,
            sameSitePolicy: .lax
        ),
        reauthorizationToken: .init(
            expires: 60 * 5,
            maxAge: 60 * 5,
            domain: nil,
            isSecure: true,
            isHTTPOnly: true,
            sameSitePolicy: .lax
        )
    )
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
        baseURL: .init(string: "/")!,
        domain: nil,
        issuer: nil,
        cookies: .testValue,
        router: Identity.API.Router().eraseToAnyParserPrinter(),
        client: .testValue
    )
}
