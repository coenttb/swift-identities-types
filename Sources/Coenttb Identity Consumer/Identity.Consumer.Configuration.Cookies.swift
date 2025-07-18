//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 17/02/2025.
//

import Coenttb_Vapor
import Dependencies
import Foundation
import Identities
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

// extension Identity.CookiesConfiguration: TestDependencyKey {
//    public static let testValue: Self = .init(
//        accessToken: {
//            var x: HTTPCookies.Configuration = .testValue
//            x.expires = 60 * 15
//            return x
//        }(),
//        refreshToken: {
//            var x: HTTPCookies.Configuration = .testValue
//            x.expires = 60 * 60 * 24 * 30
//            return x
//        }(),
//        reauthorizationToken: .testValue
//    )
// }

// extension Identity.CookiesConfiguration {
//    public static func development(
//        router: AnyParserPrinter<URLRequestData, Identity.API>
//    ) -> Self {
//        
//        let dummy = "-"
//        
//        return .init(
//            accessToken: .init(
//                expires: 60 * 15,
//                maxAge: 60 * 15,
//                domain: nil,
//                path: "/",
//                isSecure: false,
//                isHTTPOnly: true,
//                sameSitePolicy: .none  // Lax for local development across ports
//            ),
//            refreshToken: .init(
//                expires: 60 * 60 * 24 * 30,
//                maxAge: 60 * 60 * 24 * 30,
//                domain: nil,
//                path: router.url(for: .authenticate(.token(.refresh(.init(value: dummy))))).absoluteString,
//                isSecure: false,
//                isHTTPOnly: true,
//                sameSitePolicy: .none
//            ),
//            reauthorizationToken: .init(
//                expires: 60 * 5,
//                maxAge: 60 * 5,
//                domain: nil,
//                path: router.url(for: .reauthorize(.init(password: dummy))).absoluteString,
//                isSecure: false,
//                isHTTPOnly: true,
//                sameSitePolicy: .none
//            )
//        )
//    }
// }
