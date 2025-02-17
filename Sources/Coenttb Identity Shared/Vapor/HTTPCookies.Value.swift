//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import Coenttb_Vapor

extension HTTPCookies.Value {
    public init(
        token: String
    ){
        self = .init(string: token)
    }
    
    public init(
        string: String
    ){
        fatalError()
//        @Dependency(\.cookieConfiguration) var config
//        @Dependency(\.date) var date
//        
//        self = .init(
//            string: string,
//            expires: config.expires.map{ date().addingTimeInterval($0) },
//            maxAge: config.maxAge,
//            domain: config.domain,
//            path: config.path,
//            isSecure: config.isSecure,
//            isHTTPOnly: config.isHTTPOnly,
//            sameSite: config.sameSitePolicy
//        )
    }
}


