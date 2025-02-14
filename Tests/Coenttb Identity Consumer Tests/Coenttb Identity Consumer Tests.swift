//  Coenttb_Identity_Consumer_Fluent Tests.swift

import Coenttb_Identity_Consumer
import Coenttb_Vapor
import DependenciesTestSupport
import Foundation
import Mailgun
import Testing

@Test("Create a cookie and expire it")
func test1() async throws {
    // Create a response with some cookies
    let response = Response()
    response.cookies["access_token"] = .init(
        string: "test123",
        domain: "example.com",
        path: "/",
        isSecure: true,
        isHTTPOnly: true,
        sameSite: .strict
    )
    response.cookies["refresh_token"] = .init(
        string: "refresh456",
        domain: "example.com",
        path: "/",
        isSecure: true,
        isHTTPOnly: true,
        sameSite: .strict
    )

    // Verify cookies are set
    #expect(response.cookies["access_token"]?.string == "test123")
    #expect(response.cookies["refresh_token"]?.string == "refresh456")
    
    // Expire the cookies
    let cookiesToExpire: [HTTPCookies.Value?] = [
        response.cookies["access_token"],
        response.cookies["refresh_token"]
    ]
    
    response.expire(
        cookies: [
            \.["access_token"],
             \.["refresh_token"],
        ]
    )
    
    // Verify cookies are expired by checking the string is empty
    #expect(response.cookies["access_token"]?.string == "")
    #expect(response.cookies["refresh_token"]?.string == "")
    
    // Verify other attributes are preserved
    #expect(response.cookies["access_token"]?.domain == "example.com")
    #expect(response.cookies["access_token"]?.path == "/")
    #expect(response.cookies["access_token"]?.isSecure ?? false == true)
    #expect(response.cookies["access_token"]?.isHTTPOnly ?? false == true)
    #expect(response.cookies["access_token"]?.sameSite == .strict)
}
