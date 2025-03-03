//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 17/02/2025.
//

import Foundation
import Coenttb_Vapor
import Dependencies


extension Vapor.Response {
    public func withTokens(
        for response: Identity.Authentication.Response
    ) -> Vapor.Response {
       
        self.cookies.setTokens(for: response)
        
        return self
    }
}

extension HTTPCookies {
    fileprivate mutating func setTokens(for response: Identity.Authentication.Response) {
        @Dependency(\.identity.consumer.cookies.accessToken) var accessTokenConfiguration
        @Dependency(\.identity.consumer.cookies.refreshToken) var refreshTokenConfiguration

        self.accessToken = .init(token: response.accessToken.value, configuration: accessTokenConfiguration)
        self.refreshToken = .init(token: response.refreshToken.value, configuration: refreshTokenConfiguration)
    }
}
