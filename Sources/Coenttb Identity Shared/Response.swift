//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 16/10/2024.
//

import Coenttb_Vapor
import Dependencies



extension [WritableKeyPath<HTTPCookies, HTTPCookies.Value?>] {
    package static let identity: Self = [
        \.accessToken,
        \.refreshToken,
        \.reauthorizationToken
    ]
}
