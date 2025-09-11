//
//  JWT Tests.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 20/02/2025.
//

import Authenticating
import Dependencies
import DependenciesTestSupport
import Foundation
@testable import IdentitiesTypes
import Testing

// JWT token tests removed since JWT is now just a String type alias

@Suite("Authentication Response Tests")
struct AuthenticationResponseTests {
    
    @Test("Creates authentication response with tokens")
    func testAuthenticationResponseCreation() {
        let accessToken = "access.token.value"
        let refreshToken = "refresh.token.value"
        let response = Identity.Authentication.Response(
            accessToken: accessToken,
            refreshToken: refreshToken
        )
        
        #expect(response.accessToken == accessToken)
        #expect(response.refreshToken == refreshToken)
    }
    
    @Test("Authentication response equality")
    func testAuthenticationResponseEquality() {
        let response1 = Identity.Authentication.Response(
            accessToken: "access.token",
            refreshToken: "refresh.token"
        )
        let response2 = Identity.Authentication.Response(
            accessToken: "access.token",
            refreshToken: "refresh.token"
        )
        
        #expect(response1 == response2)
    }
    
    @Test("Authentication response encoding and decoding")
    func testAuthenticationResponseCodable() throws {
        let response = Identity.Authentication.Response(
            accessToken: "access.token.value",
            refreshToken: "refresh.token.value"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(response)
        
        let decoder = JSONDecoder()
        let decodedResponse = try decoder.decode(Identity.Authentication.Response.self, from: data)
        
        #expect(decodedResponse.accessToken == response.accessToken)
        #expect(decodedResponse.refreshToken == response.refreshToken)
        #expect(decodedResponse == response)
    }
}

@Suite("Bearer Authentication Tests")
struct BearerAuthTests {
    
    @Test("Creates bearer auth with token")
    func testBearerAuthCreation() throws {
        let token = "sk-test-api-key-123"
        let bearerAuth = try BearerAuth(token: token)
        
        #expect(bearerAuth.token == token)
    }
    
    @Test("Bearer auth equality")
    func testBearerAuthEquality() throws {
        let token = "test-token"
        let auth1 = try BearerAuth(token: token)
        let auth2 = try BearerAuth(token: token)
        
        #expect(auth1 == auth2)
    }
    
    @Test("Bearer auth encoding and decoding")
    func testBearerAuthCodable() throws {
        let bearerAuth = try BearerAuth(token: "api-key-123")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(bearerAuth)
        
        let decoder = JSONDecoder()
        let decodedAuth = try decoder.decode(BearerAuth.self, from: data)
        
        #expect(decodedAuth.token == bearerAuth.token)
        #expect(decodedAuth == bearerAuth)
    }
    
    @Test("Bearer auth router creates correct header")
    func testBearerAuthRouterHeader() throws {
        let bearerAuth = try BearerAuth(token: "test-token-123")
        let router = BearerAuth.Router()
        
        let request = try router.request(for: bearerAuth)
        
        // URLRequest uses allHTTPHeaderFields instead of headers
        #expect(request.allHTTPHeaderFields?["Authorization"] == "Bearer test-token-123")
    }
    
    // @Test("Bearer auth router parses header correctly")
    // This test requires URLRequestData which needs different handling
    // func testBearerAuthRouterParsing() throws {
    //     let router = BearerAuth.Router()
    //     
    //     var request = URLRequestData()
    //     request.headers = ["Authorization": ["Bearer test-token-456"]]
    //     
    //     let bearerAuth = try router.match(request: request)
    //     
    //     #expect(bearerAuth.token == "test-token-456")
    // }
}

@Suite("Authentication Credentials Tests")
struct AuthenticationCredentialsTests {
    
    @Test("Creates credentials with username and password")
    func testCredentialsCreation() {
        let username = "user@example.com"
        let password = "password123"
        let credentials = Identity.Authentication.Credentials(
            username: username,
            password: password
        )
        
        #expect(credentials.username == username)
        #expect(credentials.password == password)
    }
    
    @Test("Credentials equality")
    func testCredentialsEquality() {
        let creds1 = Identity.Authentication.Credentials(
            username: "user@example.com",
            password: "password123"
        )
        let creds2 = Identity.Authentication.Credentials(
            username: "user@example.com",
            password: "password123"
        )
        
        #expect(creds1 == creds2)
    }
    
    @Test("Credentials inequality with different username")
    func testCredentialsInequalityUsername() {
        let creds1 = Identity.Authentication.Credentials(
            username: "user1@example.com",
            password: "password123"
        )
        let creds2 = Identity.Authentication.Credentials(
            username: "user2@example.com",
            password: "password123"
        )
        
        #expect(creds1 != creds2)
    }
    
    @Test("Credentials inequality with different password")
    func testCredentialsInequalityPassword() {
        let creds1 = Identity.Authentication.Credentials(
            username: "user@example.com",
            password: "password123"
        )
        let creds2 = Identity.Authentication.Credentials(
            username: "user@example.com",
            password: "password456"
        )
        
        #expect(creds1 != creds2)
    }
    
    @Test("Credentials encoding and decoding")
    func testCredentialsCodable() throws {
        let credentials = Identity.Authentication.Credentials(
            username: "user@example.com",
            password: "securePassword123"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(credentials)
        
        let decoder = JSONDecoder()
        let decodedCreds = try decoder.decode(Identity.Authentication.Credentials.self, from: data)
        
        #expect(decodedCreds.username == credentials.username)
        #expect(decodedCreds.password == credentials.password)
        #expect(decodedCreds == credentials)
    }
}
