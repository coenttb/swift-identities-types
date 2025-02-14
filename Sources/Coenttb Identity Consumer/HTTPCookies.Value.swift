//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import Coenttb_Vapor

extension HTTPCookies {
    public struct Configuration: Sendable, Hashable {
        public var expires: TimeInterval?
        public var maxAge: Int?
        public var domain: String?
        public var path: String = "/"
        public var isSecure: Bool
        public var isHTTPOnly: Bool
        public var sameSitePolicy: HTTPCookies.SameSitePolicy
        
        public init(
            expires: TimeInterval? = nil,
            maxAge: Int? = nil,
            domain: String? = nil,
            isSecure: Bool = true,
            isHTTPOnly: Bool = true,
            sameSitePolicy: HTTPCookies.SameSitePolicy = .lax
        ) {
            self.expires = expires
            self.maxAge = maxAge
            self.domain = domain
            self.isSecure = isSecure
            self.isHTTPOnly = isHTTPOnly
            self.sameSitePolicy = sameSitePolicy
        }
    }
}

extension HTTPCookies.Value {
    public init(
        token: String
    ){
        self = .init(string: token)
    }
    
    public init(
        string: String
    ){
        @Dependency(\.cookieConfiguration) var config
        @Dependency(\.date) var date
        
        self = .init(
            string: string,
            expires: config.expires.map{ date().addingTimeInterval($0) },
            maxAge: config.maxAge,
            domain: config.domain,
            path: config.path,
            isSecure: config.isSecure,
            isHTTPOnly: config.isHTTPOnly,
            sameSite: config.sameSitePolicy
        )
    }
}

extension HTTPCookies.Configuration: DependencyKey {
    public static let liveValue: HTTPCookies.Configuration = .init(domain: nil)
    public static let testValue: HTTPCookies.Configuration = liveValue
}

extension HTTPCookies.Configuration {
    public static let localDevelopment: HTTPCookies.Configuration = .init(
        domain: "localhost",
        isSecure: false,
        isHTTPOnly: true,
        sameSitePolicy: .lax
    )
}

extension DependencyValues {
    public var cookieConfiguration: HTTPCookies.Configuration {
        get { self[HTTPCookies.Configuration.self] }
        set { self[HTTPCookies.Configuration.self] = newValue }
    }
}

extension HTTPCookies.Value {
    
    package static func accessToken(
        token: JWT.Token
    ) -> Self {
        @Dependency(\.cookieConfiguration) var config
        
        return withDependencies {
            $0.cookieConfiguration.sameSitePolicy = .lax
        } operation: {
            return HTTPCookies.Value(
                token: token.value
            )
        }
    }
    
    package static func refreshToken(
        token: JWT.Token
        //        router: AnyParserPrinter<URLRequestData, Identity.Consumer.Route>
    ) -> Self {
        @Dependency(\.cookieConfiguration) var config
        
        return withDependencies {
            //            $0.cookieConfiguration.path = router.url(for: .api(.authenticate(.token(.refresh(.init(token: token.value)))))).relativePath
            $0.cookieConfiguration.path = "/"
        } operation: {
            return .init(
                token: token.value
            )
        }
    }
}
