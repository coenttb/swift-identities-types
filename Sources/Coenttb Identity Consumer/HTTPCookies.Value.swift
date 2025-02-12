//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import Coenttb_Vapor

extension HTTPCookies.Value {
    package static func jwt(
        token: String,
        expiresIn: TimeInterval,
        path: String = "/",
        domain: String? = nil,
        isSecure: Bool = {
#if DEBUG
            return false
#elseif !DEBUG
            return true
#endif
        }(),
        isHTTPOnly: Bool = true,
        sameSite: HTTPCookies.SameSitePolicy = .lax
    ) -> HTTPCookies.Value {
        HTTPCookies.Value(
            string: token,
            expires: Date().addingTimeInterval(expiresIn),
            maxAge: Int(expiresIn),
            domain: domain,
            path: path,
            isSecure: isSecure,
            isHTTPOnly: isHTTPOnly,
            sameSite: sameSite
        )
    }
    
    package static func accessToken(
        response: Identity.Authentication.Response,
        domain: String?
    )-> Self {
        .jwt(
            token: response.accessToken.value,
            expiresIn: response.accessToken.expiresIn,
            domain: domain,
            isSecure: {
#if DEBUG
                return false
#elseif !DEBUG
                return true
#endif
}(),
            sameSite: .strict
        )
    }
    
    package static func refreshToken(response: Identity.Authentication.Response, domain: String?)-> Self {
        @Dependency(Identity.Consumer.Route.Router.self) var router
        return .jwt(
            token: response.refreshToken.value,
            expiresIn: response.refreshToken.expiresIn,
            path: router.url(for: .api(.authenticate(.token(.refresh(.init(token: response.refreshToken.value)))))).relativePath,
            domain: domain,
            isSecure: {
#if DEBUG
            return false
#elseif !DEBUG
            return true
#endif
        }()
        )
    }
}

