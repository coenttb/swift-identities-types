//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 16/10/2024.
//

import Coenttb_Vapor
import Identity_Consumer

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

extension Vapor.Response {
    public func expiring(
        cookies: [HTTPCookies.Value?]
    ) -> Vapor.Response {
        let cookieValues = cookies.compactMap { $0 }
        
        cookieValues.forEach { cookie in            
            self.cookies[cookie.string] = .expired
        }
               
        return self
    }
}

extension [HTTPCookies.Value?] {
    static var identity: [HTTPCookies.Value?]  {
        get throws {
            @Dependency(\.request) var request
            guard let request else { throw Abort.requestUnavailable }
            
            return [
                request.cookies.accessToken,
                request.cookies.refreshToken,
                request.cookies.reauthorizationToken,
            ]
        }
    }
}
