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

extension Identity {
    public struct Configuration:  Sendable {
        public let provider: Identity.Configuration.Provider
        public let consumer: Identity.Configuration.Consumer
    }
}

extension Identity.Configuration: TestDependencyKey {
    public static let testValue: Self = .init(
        provider: .testValue,
        consumer: .testValue
    )
}


extension DependencyValues {
    public var identity: Identity.Configuration {
        get { self[Identity.Configuration.self] }
        set { self[Identity.Configuration.self] = newValue }
    }
}

extension Identity.Configuration.Consumer: TestDependencyKey {
    public static let testValue: Self = .init(
        baseURL: .init(string: "")!,
        domain: nil,
        cookies: .testValue
    )
}

extension Identity.Configuration {
    public struct Consumer: Sendable {
        public let baseURL: URL
        public let domain: String?
        public let router: AnyParserPrinter<URLRequestData, Identity.Consumer.Route>
        public let cookies: Identity.CookiesConfiguration
        
        public init(
            baseURL: URL,
            domain: String?,
            cookies: Identity.CookiesConfiguration,
            router: AnyParserPrinter<URLRequestData, Identity.Consumer.Route> = Identity.Consumer.Route.Router().eraseToAnyParserPrinter()
        ) {
            self.baseURL = baseURL
            self.domain = domain
            self.cookies = cookies
            self.router = router.baseURL(baseURL.absoluteString).eraseToAnyParserPrinter()
        }
    }
}

extension Identity.Configuration {
    public struct Provider: Sendable {
        public let baseURL: URL
        public let domain: String?
        public let router: AnyParserPrinter<URLRequestData, Identity.API>
        
        public init(
            baseURL: URL,
            domain: String?,
            router: AnyParserPrinter<URLRequestData, Identity.API> = Identity.API.Router().eraseToAnyParserPrinter()
        ) {
            self.baseURL = baseURL
            self.domain = domain
            self.router = router.baseURL(baseURL.absoluteString).eraseToAnyParserPrinter()
        }
    }
}


extension Identity.Configuration.Provider: TestDependencyKey {
    public static let testValue: Self = .init(
        baseURL: .init(string: "")!,
        domain: nil
    )
}
