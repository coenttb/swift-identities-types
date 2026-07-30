//
//  JWT Tests.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 20/02/2025.
//

import Dependencies
import Dependencies_Test_Support
import Foundation
import Testing

@testable import IdentitiesTypes

// JWT token tests removed since JWT is now just a String type alias

extension Identity.Authentication.Response {
    @Suite
    struct Test {

        @Test
        func `Creates authentication response with tokens`() {
            let accessToken = "access.token.value"
            let refreshToken = "refresh.token.value"
            let response = Identity.Authentication.Response(
                accessToken: accessToken,
                refreshToken: refreshToken
            )

            #expect(response.accessToken == accessToken)
            #expect(response.refreshToken == refreshToken)
        }

        @Test
        func `Authentication response equality`() {
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

        @Test
        func `Authentication response encoding and decoding`() throws {
            let response = Identity.Authentication.Response(
                accessToken: "access.token.value",
                refreshToken: "refresh.token.value"
            )

            let encoder = JSONEncoder()
            let data = try encoder.encode(response)

            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(
                Identity.Authentication.Response.self,
                from: data
            )

            #expect(decodedResponse.accessToken == response.accessToken)
            #expect(decodedResponse.refreshToken == response.refreshToken)
            #expect(decodedResponse == response)
        }
    }
}

extension RFC_6750.Bearer {
    @Suite
    struct Test {

        @Test
        func `Creates bearer auth with token`() throws {
            let token = "sk-test-api-key-123"
            let bearerAuth = try RFC_6750.Bearer(token: token)

            #expect(bearerAuth.token == token)
        }

        @Test
        func `Bearer auth equality`() throws {
            let token = "test-token"
            let auth1 = try RFC_6750.Bearer(token: token)
            let auth2 = try RFC_6750.Bearer(token: token)

            #expect(auth1 == auth2)
        }

        @Test
        func `Bearer auth encoding and decoding`() throws {
            let bearerAuth = try RFC_6750.Bearer(token: "api-key-123")

            let encoder = JSONEncoder()
            let data = try encoder.encode(bearerAuth)

            let decoder = JSONDecoder()
            let decodedAuth = try decoder.decode(RFC_6750.Bearer.self, from: data)

            #expect(decodedAuth.token == bearerAuth.token)
            #expect(decodedAuth == bearerAuth)
        }

        @Test
        func `Bearer auth router creates correct header`() throws {
            let bearerAuth = try RFC_6750.Bearer(token: "test-token-123")
            let router = RFC_6750.Bearer.Router()

            let request = try router.request(for: bearerAuth)

            // URLRequest uses allHTTPHeaderFields instead of headers
            #expect(request.allHTTPHeaderFields?["Authorization"] == "Bearer test-token-123")
        }

        // @Test
        // This test requires URLRequestData which needs different handling
        // func `Bearer router parses the Authorization header`() throws {
        //     let router = RFC_6750.Bearer.Router()
        //
        //     var request = URLRequestData()
        //     request.headers = ["Authorization": ["Bearer test-token-456"]]
        //
        //     let bearerAuth = try router.match(request: request)
        //
        //     #expect(bearerAuth.token == "test-token-456")
        // }
    }
}

extension Identity.Authentication.Credentials {
    @Suite
    struct Test {

        @Test
        func `Creates credentials with username and password`() {
            let username = "user@example.com"
            let password = "password123"
            let credentials = Identity.Authentication.Credentials(
                username: username,
                password: password
            )

            #expect(credentials.username == username)
            #expect(credentials.password == password)
        }

        @Test
        func `Credentials equality`() {
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

        @Test
        func `Credentials inequality with different username`() {
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

        @Test
        func `Credentials inequality with different password`() {
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

        @Test
        func `Credentials encoding and decoding`() throws {
            let credentials = Identity.Authentication.Credentials(
                username: "user@example.com",
                password: "securePassword123"
            )

            let encoder = JSONEncoder()
            let data = try encoder.encode(credentials)

            let decoder = JSONDecoder()
            let decodedCreds = try decoder.decode(
                Identity.Authentication.Credentials.self,
                from: data
            )

            #expect(decodedCreds.username == credentials.username)
            #expect(decodedCreds.password == credentials.password)
            #expect(decodedCreds == credentials)
        }
    }
}
