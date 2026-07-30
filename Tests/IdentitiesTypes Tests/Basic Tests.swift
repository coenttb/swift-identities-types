//
//  Basic Tests.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 20/02/2025.
//

import Dependencies
import Dependencies_Test_Support
import EmailAddress
import Foundation
import Testing

@testable import IdentitiesTypes

extension Identity.Authentication {
    @Suite
    struct Test {

        @Test
        func `Authentication response with string tokens`() {
            let response = Identity.Authentication.Response(
                accessToken: "access.token.string",
                refreshToken: "refresh.token.string"
            )

            #expect(response.accessToken == "access.token.string")
            #expect(response.refreshToken == "refresh.token.string")
            #expect(response.accessToken.isEmpty == false)
            #expect(response.refreshToken.isEmpty == false)
        }

        @Test
        func `Authentication response equality`() {
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

        @Test
        func `Authentication response encoding and decoding`() throws {
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
}

extension Identity._TestDatabase {
    @Suite(.dependencies)
    struct Test {

        @Test
        func `Successfully authenticates with valid credentials`() async throws {
            try await Identity._TestDatabase.Helper.withIsolatedDatabase {
                @Dependency(\.identity) var identity

                let email = "test@example.com"
                let password = "password123"

                // Create and verify identity
                try await identity.create.request(email: email, password: password)
                try await identity.create.verify(email: email, token: "verification-token-\(email)")

                // Login
                let response = try await identity.login(username: email, password: password)

                // Check tokens are returned as strings
                #expect(response.accessToken.isEmpty == false)
                #expect(response.refreshToken.isEmpty == false)
            }
        }

        @Test
        func `Fails authentication with invalid credentials`() async throws {
            try await Identity._TestDatabase.Helper.withIsolatedDatabase {
                @Dependency(\.identity) var identity

                await #expect(throws: Identity._TestDatabase.TestError.invalidCredentials) {
                    try await identity.login(
                        username: "nonexistent@example.com",
                        password: "wrongpass"
                    )
                }
            }
        }

        @Test
        func `Successfully creates new identity`() async throws {
            try await Identity._TestDatabase.Helper.withIsolatedDatabase {
                @Dependency(\.identity) var identity

                let email = "new@example.com"
                let password = "securePass123"

                try await identity.create.request(email: email, password: password)
                try await identity.create.verify(email: email, token: "verification-token-\(email)")

                let response = try await identity.login(username: email, password: password)
                #expect(response.accessToken.isEmpty == false)
            }
        }
    }
}
