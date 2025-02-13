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
        self.cookies.accessToken = .accessToken(response: tokens, domain: nil)
        self.cookies.refreshToken = .refreshToken(response: tokens, domain: nil)
        self.cookies.refreshToken?.sameSite = .strict
        self.cookies.refreshToken?.isHTTPOnly = true
        
        return self
    }
}

