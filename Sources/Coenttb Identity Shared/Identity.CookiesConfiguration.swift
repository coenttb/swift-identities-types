//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 17/02/2025.
//

import Foundation
import Identity_Shared
import Dependencies
import Vapor
import Coenttb_Vapor

extension Identity {
    public struct CookiesConfiguration: Sendable, Hashable {
        public var accessToken: HTTPCookies.Configuration
        public var refreshToken: HTTPCookies.Configuration
        public var reauthorizationToken: HTTPCookies.Configuration
        
        public init(
            accessToken: HTTPCookies.Configuration,
            refreshToken: HTTPCookies.Configuration,
            reauthorizationToken: HTTPCookies.Configuration
        ) {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
            self.reauthorizationToken = reauthorizationToken
        }
    }
}

extension Identity.CookiesConfiguration: TestDependencyKey {
    public static let testValue: Self = .init(
        accessToken: .testValue,
        refreshToken: .testValue,
        reauthorizationToken: .testValue
    )
}

extension Identity.CookiesConfiguration {
    public static let development: Self = .init(
        accessToken: .init(
            expires: 60 * 15,
            maxAge: 60 * 15,
            domain: nil,
            isSecure: false,
            isHTTPOnly: true,
            sameSitePolicy: .lax  // Lax for local development across ports
        ),
        refreshToken: .init(
            expires: 60 * 60 * 24 * 30,
            maxAge: 60 * 60 * 24 * 30,
            domain: nil,
            path: "",
            isSecure: false,
            isHTTPOnly: true,
            sameSitePolicy: .lax
        ),
        reauthorizationToken: .init(
            expires: 60 * 5,
            maxAge: 60 * 5,
            domain: nil,
            isSecure: false,
            isHTTPOnly: true,
            sameSitePolicy: .lax
        )
    )
}
