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
        public var path: String?
        public var isSecure: Bool
        public var isHTTPOnly: Bool
        public var sameSitePolicy: HTTPCookies.SameSitePolicy
        
        public init(
            expires: TimeInterval,
            maxAge: Int? = nil,
            domain: String? = nil,
            path: String? = nil,
            isSecure: Bool = true,
            isHTTPOnly: Bool = true,
            sameSitePolicy: HTTPCookies.SameSitePolicy = .lax
        ) {
            self.expires = expires
            self.maxAge = maxAge
            self.domain = domain
            self.path = path
            self.isSecure = isSecure
            self.isHTTPOnly = isHTTPOnly
            self.sameSitePolicy = sameSitePolicy
        }
    }
}

extension HTTPCookies.Configuration: TestDependencyKey {
    public static let testValue: HTTPCookies.Configuration = .init(expires: 60*60*24)
}

extension HTTPCookies.Configuration {
    public static let localDevelopment: HTTPCookies.Configuration = .init(
        expires: 60*60*24,
        domain: nil,
        isSecure: false,
        isHTTPOnly: true,
        sameSitePolicy: .lax
    )
}
