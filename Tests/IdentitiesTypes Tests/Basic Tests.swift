//
//  Basic Tests.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 20/02/2025.
//

import Dependencies
import DependenciesTestSupport
import EmailAddress
import Foundation
@testable import Identities
import Testing

@Suite("Basic Authentication Tests")
struct BasicAuthenticationTests {
    
    @Test("Authentication response with string tokens")
    func testAuthenticationResponse() {
        let response = Identity.Authentication.Response(
            accessToken: "access.token.string",
            refreshToken: "refresh.token.string"
        )
        
        #expect(response.accessToken == "access.token.string")
        #expect(response.refreshToken == "refresh.token.string")
        #expect(response.accessToken.isEmpty == false)
        #expect(response.refreshToken.isEmpty == false)
    }
    
    @Test("Authentication response equality")
    func testAuthenticationResponseEquality() {
        let response1 = Identity.Authentication.Response(
            accessToken: "token1",
            refreshToken: "token2"
        )
        let response2 = Identity.Authentication.Response(
            accessToken: "token1",
            refreshToken: "token2"
        )
        
        #expect(response1 == response2)
    }
    
    @Test("Authentication response encoding and decoding")
    func testAuthenticationResponseCodable() throws {
        let response = Identity.Authentication.Response(
            accessToken: "access.jwt.token",
            refreshToken: "refresh.jwt.token"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(response)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Identity.Authentication.Response.self, from: data)
        
        #expect(decoded.accessToken == response.accessToken)
        #expect(decoded.refreshToken == response.refreshToken)
        #expect(decoded == response)
    }
}

@Suite("Basic Identity Tests")
struct BasicIdentityTests {
    
    @Test("Successfully authenticates with valid credentials") 
    func testValidCredentialsAuthentication() async throws {
        try await Identity.Client._TestDatabase.Helper.withIsolatedDatabase {
            @Dependency(Identity.Client.self) var client
            
            let email = "test@example.com"
            let password = "password123"
            
            // Create and verify identity
            try await client.create.request(email: email, password: password)
            try await client.create.verify(email: email, token: "verification-token-\(email)")
            
            // Login
            let response = try await client.login(username: email, password: password)
            
            // Check tokens are returned as strings
            #expect(response.accessToken.isEmpty == false)
            #expect(response.refreshToken.isEmpty == false)
        }
    }
    
    @Test("Fails authentication with invalid credentials")
    func testInvalidCredentialsAuthentication() async throws {
        try await Identity.Client._TestDatabase.Helper.withIsolatedDatabase {
            @Dependency(Identity.Client.self) var client
            
            await #expect(throws: Identity.Client._TestDatabase.TestError.invalidCredentials) {
                try await client.login(username: "nonexistent@example.com", password: "wrongpass")
            }
        }
    }
    
    @Test("Successfully creates new identity")
    func testIdentityCreation() async throws {
        try await Identity.Client._TestDatabase.Helper.withIsolatedDatabase {
            @Dependency(Identity.Client.self) var client
            
            let email = "new@example.com"
            let password = "securePass123"
            
            try await client.create.request(email: email, password: password)
            try await client.create.verify(email: email, token: "verification-token-\(email)")
            
            let response = try await client.login(username: email, password: password)
            #expect(response.accessToken.isEmpty == false)
        }
    }
}
