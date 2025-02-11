//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 11/02/2025.
//

import Foundation
import Coenttb_Vapor

extension HTTPCookies {
    public var accessToken: HTTPCookies.Value? {
        get {
            self["access_token"]
        }
        set {
            self["access_token"] = newValue
        }
    }
    
    public var refreshToken: HTTPCookies.Value? {
        get {
            self["refresh_token"]
        }
        set {
            self["refresh_token"] = newValue
        }
    }
}
