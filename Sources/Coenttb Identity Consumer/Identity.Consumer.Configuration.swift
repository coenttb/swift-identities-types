//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 14/02/2025.
//

import Foundation
import Dependencies
import Identity_Shared
import Identity_Consumer
import Coenttb_Identity_Shared
import URLRouting

extension Identity.Consumer {
    public struct Configuration:  Sendable {
        public var provider: Identity.Consumer.Configuration.Provider
        public var consumer: Identity.Consumer.Configuration.Consumer
        
        public init(provider: Identity.Consumer.Configuration.Provider, consumer: Identity.Consumer.Configuration.Consumer) {
            self.provider = provider
            self.consumer = consumer
        }
    }
}

extension Identity.Consumer.Configuration: TestDependencyKey {
    public static let testValue: Self = .init(
        provider: .testValue,
        consumer: .testValue
    )
}


extension DependencyValues {
    public var identity: Identity.Consumer.Configuration {
        get { self[Identity.Consumer.Configuration.self] }
        set { self[Identity.Consumer.Configuration.self] = newValue }
    }
}

extension Identity.Consumer.Configuration.Consumer: TestDependencyKey {
    public static let testValue: Self = .init(
        baseURL: .init(string: "")!,
        domain: nil,
        cookies: .testValue,
        router: Identity.Consumer.Route.Router().eraseToAnyParserPrinter(),
        client: .testValue
    )
}

extension Identity.Consumer.Configuration {
    public struct Consumer: Sendable {
        public var baseURL: URL
        public var domain: String?
        public var cookies: Identity.CookiesConfiguration
        public var router: AnyParserPrinter<URLRequestData, Identity.Consumer.Route>
        public var client: Identity.Consumer.Client
        
        public init(
            baseURL: URL,
            domain: String?,
            cookies: Identity.CookiesConfiguration = .live,
            router: AnyParserPrinter<URLRequestData, Identity.Consumer.Route>,
            client: Identity.Consumer.Client
        ) {
            self.baseURL = baseURL
            self.domain = domain
            self.cookies = cookies
            self.router = router.baseURL(baseURL.absoluteString).eraseToAnyParserPrinter()
            self.client = client
            
            if self.cookies.refreshToken.path == nil {
                self.cookies.refreshToken.path = self.router.url(for: .api(.authenticate(.token(.refresh(.init(token: "--------------------")))))).absoluteString
            }
        }
    }
}

extension Identity.Consumer.Configuration {
    public struct Provider: Sendable {
        public var baseURL: URL
        public var domain: String?
        public var router: AnyParserPrinter<URLRequestData, Identity.API>
        
        public init(
            baseURL: URL,
            domain: String?,
            router: AnyParserPrinter<URLRequestData, Identity.API>
        ) {
            self.baseURL = baseURL
            self.domain = domain
            self.router = router.baseURL(baseURL.absoluteString).eraseToAnyParserPrinter()
        }
    }
}

extension Identity.Consumer.Configuration.Provider: TestDependencyKey {
    public static let testValue: Self = .init(
        baseURL: .init(string: "")!,
        domain: nil,
        router: Identity.API.Router().eraseToAnyParserPrinter()
    )
}

extension Identity.CookiesConfiguration {
    public static let live: Identity.CookiesConfiguration = {
//        @Dependency(\.identity.consumer.router) var router
        
        return .init(
            accessToken: .init(
                expires: 60 * 15, // 15 minutes
                maxAge: 60 * 15,
                domain: nil,
                isSecure: true,
                isHTTPOnly: true,
                sameSitePolicy: .strict
            ),
            refreshToken: .init(
                expires: 60 * 60 * 24 * 30, // 30 days
                maxAge: 60 * 60 * 24 * 30,
                domain: nil,
//                path: router.url(for: .api(.authenticate(.token(.refresh(.init(token: "--------------------")))))).absoluteString,
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
                sameSitePolicy: .strict
            )
        )
    }()
}

