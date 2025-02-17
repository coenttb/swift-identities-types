//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import Coenttb_Vapor

extension HTTPCookies {
    public struct Configuration: Sendable, Hashable {
        public var expires: TimeInterval
        public var maxAge: Int?
        public var domain: String?
        public var path: String = "/"
        public var isSecure: Bool
        public var isHTTPOnly: Bool
        public var sameSitePolicy: HTTPCookies.SameSitePolicy
        
        public init(
            expires: TimeInterval = 0,
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

extension HTTPCookies.Configuration: DependencyKey {
    public static let liveValue: HTTPCookies.Configuration = .init(domain: nil)
    public static let testValue: HTTPCookies.Configuration = liveValue
}

extension HTTPCookies.Configuration {
    public static let localDevelopment: HTTPCookies.Configuration = .init(
        domain: nil,
        isSecure: false,
        isHTTPOnly: true,
        sameSitePolicy: .lax
    )
}
