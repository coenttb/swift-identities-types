//  Coenttb_Identity_Consumer_Fluent Tests.swift

import Coenttb_Identity_Consumer
import Coenttb_Identity_Shared
import Coenttb_Vapor
import DependenciesTestSupport
import Foundation
import Mailgun
import Testing
import Dependencies
import URLRouting
import JWT
import VaporTesting

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
       
    response.expire(
        cookies: [
            \.["access_token"],
             \.["refresh_token"],
        ]
    )
    
    // Verify cookies are expired by checking the string is empty
//    #expect(response.cookies["access_token"]?.string == "")
//    #expect(response.cookies["refresh_token"]?.string == "")
    
    // Verify other attributes are preserved
    #expect(response.cookies["access_token"]?.domain == "example.com")
    #expect(response.cookies["access_token"]?.path == "/")
    #expect(response.cookies["access_token"]?.isSecure ?? false == true)
    #expect(response.cookies["access_token"]?.isHTTPOnly ?? false == true)
    #expect(response.cookies["access_token"]?.sameSite == .strict)
}

@Suite("Identity Consumer Authentication Flow Tests")
struct IdentityConsumerAuthTests {
    @Test("Test token refresh flow")
    func testTokenRefreshFlow() async throws {
        // Create a dependency context for testing
        try await withDependencies { dependencies in
            // Setup a test app with JWT key support
            let app = try await Application.make(.testing)
            let key = ES256PrivateKey()
            await app.jwt.keys.add(ecdsa: key)
            
            // Mock identity values
            let identityId = UUID()
            let email = "test@example.com"
            
            // Create JWT tokens (access and refresh)
            let accessToken = JWT.Token.Access(
                expiration: .init(value: Date().addingTimeInterval(60)), // 1 minute
                issuedAt: .init(value: Date()),
                identityId: identityId, 
                tokenId: .init(value: UUID().uuidString),
                email: try .init(email)
            )
            
            let refreshToken = JWT.Token.Refresh(
                expiration: .init(value: Date().addingTimeInterval(3600)), // 1 hour
                issuedAt: .init(value: Date()),
                identityId: identityId,
                tokenId: .init(value: UUID().uuidString),
                sessionVersion: 1
            )
            
            // Sign tokens with ES256 keys
            let signedAccessToken = try await app.jwt.keys.sign(accessToken)
            let signedRefreshToken = try await app.jwt.keys.sign(refreshToken)
            
            // Create authentication response for mocking
            let authResponse = Identity.Authentication.Response(
                accessToken: .init(value: signedAccessToken),
                refreshToken: .init(value: signedRefreshToken),
                identityId: identityId
            )
            
            // Setup mock client that returns our test tokens
            let mockClient = Identity.Consumer.Client(
                makeRequest: { _ in 
                    fatalError("Not implemented for test") 
                },
                handleRequest: { _, type in
                    // This simulates the provider returning a new token pair
                    return authResponse as! (type as! any Decodable.Type) as! Decodable
                }
            )
            
            dependencies.identity.consumer.client = mockClient
            
            // Create the authenticate client with our dependencies
            let authClient = Identity.Consumer.Client.Authenticate.live()
            
            // Test the token refresh flow
            let result = try await authClient.token.refresh(signedRefreshToken)
            
            // Verify the result
            #expect(result.accessToken.value == signedAccessToken)
            #expect(result.refreshToken.value == signedRefreshToken)
            #expect(result.identityId == identityId)
            
            try await app.asyncShutdown()
        }
    }
    
    @Test("Test token refresh with expired token")
    func testExpiredTokenRefresh() async throws {
        // Create a dependency context for testing
        try await withDependencies { dependencies in
            // Setup a test app with JWT key support
            let app = try await Application.make(.testing)
            let key = ES256PrivateKey()
            await app.jwt.keys.add(ecdsa: key)
            
            // Create an expired refresh token
            let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
            let expiredDate = pastDate.addingTimeInterval(1) // 1 second after (expired)
            
            let expiredToken = JWT.Token.Refresh(
                expiration: .init(value: expiredDate),
                issuedAt: .init(value: pastDate),
                identityId: UUID(),
                tokenId: .init(value: UUID().uuidString),
                sessionVersion: 1
            )
            
            // Sign the expired token
            let signedExpiredToken = try await app.jwt.keys.sign(expiredToken)
            
            // Setup mock client that throws an error to simulate provider rejecting expired token
            let mockClient = Identity.Consumer.Client(
                makeRequest: { _ in 
                    fatalError("Not implemented for test") 
                },
                handleRequest: { _, _ in
                    throw Abort(.unauthorized, reason: "Invalid refresh token")
                }
            )
            
            dependencies.identity.consumer.client = mockClient
            
            // Create the authenticate client with our dependencies
            let authClient = Identity.Consumer.Client.Authenticate.live()
            
            // Test the token refresh flow with expired token
            do {
                let _ = try await authClient.token.refresh(signedExpiredToken)
                #expect(false, "Expected refresh to fail with expired token")
            } catch {
                // Should throw unauthorized error
                let abort = error as? Abort
                #expect(abort != nil)
                #expect(abort?.status == .unauthorized)
            }
            
            try await app.asyncShutdown()
        }
    }
    
    @Test("Test token refresh with session version mismatch")
    func testSessionVersionMismatchRefresh() async throws {
        // Create a dependency context for testing
        try await withDependencies { dependencies in
            // Setup a test app with JWT key support
            let app = try await Application.make(.testing)
            let key = ES256PrivateKey()
            await app.jwt.keys.add(ecdsa: key)
            
            // Create a valid token but with outdated session version
            let validToken = JWT.Token.Refresh(
                expiration: .init(value: Date().addingTimeInterval(3600)),
                issuedAt: .init(value: Date()),
                identityId: UUID(),
                tokenId: .init(value: UUID().uuidString),
                sessionVersion: 1 // This is outdated compared to "current" version in mock
            )
            
            // Sign the token
            let signedToken = try await app.jwt.keys.sign(validToken)
            
            // Setup mock client that throws an error simulating session version mismatch
            let mockClient = Identity.Consumer.Client(
                makeRequest: { _ in 
                    fatalError("Not implemented for test") 
                },
                handleRequest: { _, _ in
                    throw Abort(.unauthorized, reason: "Token has been revoked")
                }
            )
            
            dependencies.identity.consumer.client = mockClient
            
            // Create the authenticate client with our dependencies
            let authClient = Identity.Consumer.Client.Authenticate.live()
            
            // Test the token refresh flow with token having wrong session version
            do {
                let _ = try await authClient.token.refresh(signedToken)
                #expect(false, "Expected refresh to fail with session version mismatch")
            } catch {
                // Should throw unauthorized error
                let abort = error as? Abort
                #expect(abort != nil)
                #expect(abort?.status == .unauthorized)
            }
            
            try await app.asyncShutdown()
        }
    }
}
