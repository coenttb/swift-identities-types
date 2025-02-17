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

extension Identity {
    public struct Configuration:  Sendable {
        public var provider: Identity.Configuration.Provider
    }
}

extension Identity.Configuration {
    public struct Provider: Sendable {
        public var baseURL: URL
        public var domain: String?
        public var router: AnyParserPrinter<URLRequestData, Identity.API>
        public var cookies: Identity.CookiesConfiguration
        
        public init(
            baseURL: URL,
            domain: String?,
            cookies: Identity.CookiesConfiguration,
            router: AnyParserPrinter<URLRequestData, Identity.API> = Identity.API.Router().eraseToAnyParserPrinter()
        ) {
            self.baseURL = baseURL
            self.domain = domain
            self.cookies = cookies
            self.router = router.baseURL(baseURL.absoluteString).eraseToAnyParserPrinter()
        }
    }
}

extension Identity.Configuration: TestDependencyKey {
    public static let testValue: Self = .init(provider: .testValue)
}

extension DependencyValues {
    public var identity: Identity.Configuration {
        get { self[Identity.Configuration.self] }
        set { self[Identity.Configuration.self] = newValue }
    }
}

extension Identity.Configuration.Provider: TestDependencyKey {
    public static let testValue: Self = .init(
        baseURL: .init(string: "")!,
        domain: nil,
        cookies: .testValue
    )
}

