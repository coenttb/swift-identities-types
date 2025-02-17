//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 16/10/2024.
//

import Coenttb_Vapor

extension Vapor.Response {
    public func with(
        _ tokens: Identity.Authentication.Response,
        domain: String?
    ) -> Vapor.Response {
        self.cookies.accessToken = .accessToken(token: tokens.accessToken)
        self.cookies.refreshToken = .refreshToken(token: tokens.refreshToken)
        self.cookies.refreshToken?.sameSite = .strict
        self.cookies.refreshToken?.isHTTPOnly = true
        
        return self
    }
}

extension [WritableKeyPath<HTTPCookies, HTTPCookies.Value?>] {
    package static let identity: Self = [
        \.accessToken,
        \.refreshToken,
        \.reauthorizationToken
    ]
}
