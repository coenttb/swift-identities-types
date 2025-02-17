//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 17/02/2025.
//

import Foundation
import Identity_Shared
import Dependencies
import Vapor

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
