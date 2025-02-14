//  Coenttb_Identity_Consumer_Fluent Tests.swift

import Coenttb_Identity_Consumer
import Coenttb_Vapor
import DependenciesTestSupport
import Foundation
import Mailgun
import Testing

@Suite("Coenttb Identity Consumer Tests")
struct EmailTests {
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
        
        let response2 = response.expiring(cookies: cookiesToExpire)
        
        // Verify cookies are expired
        #expect(response2.cookies["access_token"]?.expires == .distantPast)
        #expect(response2.cookies["refresh_token"]?.expires == .distantPast)
        
        // Verify other attributes are preserved
        #expect(response2.cookies["access_token"]?.domain == "example.com")
        #expect(response2.cookies["access_token"]?.path == "/")
        #expect(response2.cookies["access_token"]?.isSecure ?? false == true)
        #expect(response2.cookies["access_token"]?.isHTTPOnly ?? false == true)
        #expect(response2.cookies["access_token"]?.sameSite == .strict)
    }
}
