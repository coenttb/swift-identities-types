//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import Coenttb_Vapor

extension HTTPCookies.Value {
    public init(
        token: String,
        configuration: HTTPCookies.Configuration
    ){
        self = .init(string: token)
    }
    
    public init(
        string: String,
        configuration: HTTPCookies.Configuration
    ){
        @Dependency(\.date) var date
        
        self = .init(
            string: string,
            expires: date().addingTimeInterval(configuration.expires),
            maxAge: configuration.maxAge,
            domain: configuration.domain,
            path: configuration.path,
            isSecure: configuration.isSecure,
            isHTTPOnly: configuration.isHTTPOnly,
            sameSite: configuration.sameSitePolicy
        )
    }
}


