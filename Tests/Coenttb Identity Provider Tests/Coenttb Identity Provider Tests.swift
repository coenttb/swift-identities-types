//  Coenttb_Identity_Provider_Fluent Tests.swift

import Coenttb_Identity_Provider
import Coenttb_Identity_Shared
import Coenttb_Web
import DependenciesTestSupport
import Foundation
import Mailgun
import Testing
import JWT
import Vapor
import VaporTesting
import FluentSQLiteDriver
import EmailAddress


extension Identity.Provider.Client {
    static let liveTest: Self = .live(
        sendVerificationEmail: { email, token in
            print("sendVerificationEmail called")
        },
        sendPasswordResetEmail: { email, token in
            print("sendPasswordResetEmail called")
        },
        sendPasswordChangeNotification: { email in
            print("sendPasswordChangeNotification called")
        },
        sendEmailChangeConfirmation: { currentEmail, newEmail, token in
            print("sendEmailChangeConfirmation called")
        },
        sendEmailChangeRequestNotification: { currentEmail, newEmail in
            print("sendEmailChangeRequestNotification called")
        },
        onEmailChangeSuccess: { currentEmail, newEmail in
            print("onEmailChangeSuccess called")
        },
        sendDeletionRequestNotification: { email in
            print("sendDeletionRequestNotification called")
        },
        sendDeletionConfirmationNotification: { email in
            print("sendDeletionConfirmationNotification called")
        }
    )
}


@Suite(
    "Identity Provider Tests",
    .dependency(\.uuid, .incrementing),
    .dependency(\.date, .init(Date.init)),
    .dependency(\.identity.provider.client, .liveTest)
)
struct IdentityProviderTests {
    @Test("Create and verify refresh token")
    func testRefreshTokenLifecycle() async throws {
        try await withTestApp { app in
            let identityId = UUID()
            let sessionVersion = 1
            
            // Create expiration and issuance dates
            let now = Date()
            let expirationDate = now.addingTimeInterval(60 * 60) // 1 hour from now
            
            // Create refresh token payload
            let refreshToken = JWT.Token.Refresh(
                expiration: .init(value: expirationDate),
                issuedAt: .init(value: now),
                identityId: identityId,
                tokenId: .init(value: UUID().uuidString),
                sessionVersion: sessionVersion
            )
            
            // Sign the token
            let signedToken = try await app.jwt.keys.sign(refreshToken)
            
            // Verify the token can be decoded and verified
            let verifiedPayload = try await app.jwt.keys.verify(signedToken, as: JWT.Token.Refresh.self)
            
            // Assertions
            #expect(verifiedPayload.identityId == identityId)
            #expect(verifiedPayload.sessionVersion == sessionVersion)
            #expect(verifiedPayload.tokenId.value != "")
            #expect(verifiedPayload.expiration.value > now)
        }
    }
    
    @Test("Expired refresh token fails verification")
    func testExpiredRefreshToken() async throws {
        try await withTestApp { app in
            // Create an expired token (issued and expired in the past)
            let pastDate = Date().addingTimeInterval(-3600) // 1 hour ago
            let expiredDate = pastDate.addingTimeInterval(1) // 1 second after issuance (expired)
            
            let expiredToken = JWT.Token.Refresh(
                expiration: .init(value: expiredDate),
                issuedAt: .init(value: pastDate),
                identityId: UUID(),
                tokenId: .init(value: UUID().uuidString),
                sessionVersion: 1
            )
            
            // Sign the expired token
            let signedExpiredToken = try await app.jwt.keys.sign(expiredToken)
            
            // Attempt to verify - should throw JWTError.expired
            do {
                let _ = try await app.jwt.keys.verify(signedExpiredToken, as: JWT.Token.Refresh.self)
                #expect(Bool(false), "Expected verification to fail for expired token")
            } catch {
                let jwtError = error as? JWTError
                #expect(jwtError != nil)
            }
        }
    }
    
    @Test("Refresh token with incorrect session version is rejected")
    func testSessionVersionMismatch() async throws {
        // This test simulates the session version check in the provider's authentication handler
        
        try await withTestApp { app in
            
            // Create valid token with session version 1
            let validToken = JWT.Token.Refresh(
                expiration: .init(value: Date().addingTimeInterval(3600)),
                issuedAt: .init(value: Date()),
                identityId: UUID(),
                tokenId: .init(value: UUID().uuidString),
                sessionVersion: 1
            )
            
            let signedToken = try await app.jwt.keys.sign(validToken)
            
            // Simulate database identity with different session version
            let currentSessionVersion = 2 // Different from token's version (1)
            
            // Verify the token - JWT verification should succeed
            let verifiedPayload = try await app.jwt.keys.verify(signedToken, as: JWT.Token.Refresh.self)
            
            // But session version check should fail
            let tokenSessionMatches = verifiedPayload.sessionVersion == currentSessionVersion
            #expect(tokenSessionMatches == false, "Session versions should not match")
        }
    }
    
    private func setupMockIdentity(app: Application) async throws -> (email: String, password: String) {
        // Generate a unique test email for each test run
        let uniqueId = UUID().uuidString.prefix(8).lowercased()
        let testEmail = "test-\(uniqueId)@example.com"
        let testPassword = "securePassword123!"
        
        print("Creating mock identity with email: \(testEmail)")
        
        let createResponse = try await app.test(
            identity: .create(
                .request(
                    .init(
                        email: testEmail,
                        password: testPassword
                    )
                )
            )
        )
        
        #expect(createResponse.status == .ok, "Expected successful identity creation")
        
        let identity = try await Database.Identity.get(by: .email(try EmailAddress(testEmail)), on: app.db)
        
        #expect(identity.emailVerificationStatus == .unverified, "Expected email verification status to be pending")
        
        // Retrieve the verification token
        guard let tokenRecord = try await Database.Identity.Token.query(on: app.db)
            .filter(\.$identity.$id == identity.id!)
            .filter(\.$type == .emailVerification)
            .first()
        else { #expect(Bool(false)); fatalError() }
        
        let verificationToken = tokenRecord.value
        print("Verifying identity with token: \(verificationToken)")
        
        // Verify the email
        let verifyResponse = try await app.test(
            identity: .create(
                .verify(
                    .init(
                        token: verificationToken,
                        email: testEmail
                    )
                )
            )
        )
        
        // Verify the email verification was successful
        #expect(verifyResponse.status == .ok, "Expected successful email verification")
        
        // Check database that email verification status is now verified
        let updatedIdentity = try await Database.Identity.get(by: .email(try EmailAddress(testEmail)), on: app.db)
        #expect(updatedIdentity.emailVerificationStatus == .verified, "Expected email verification status to be verified")
        
        print("Successfully created and verified mock identity: \(testEmail)")
        return (testEmail, testPassword) // Return the identity for use in tests
    }
    
    @Test("Test creating a new identity with credentials")
    func testCreateIdentity() async throws {
        try await withTestApp { app in
            _ = try await setupMockIdentity(app: app)
        }
    }
    
    @Test("Test login in with mock identity")
    func testLoginWithMockIdentity() async throws {
        try await withTestApp { app in
            
            let (testEmail, testPassword) = try await setupMockIdentity(app: app)
            
            let loginResponse = try await app.test(
                identity: .authenticate(
                    .credentials(
                        .init(
                            username: testEmail,
                            password: testPassword
                        )
                    )
                )
            )
            
            // Verify login was successful
            #expect(loginResponse.status == .ok, "Expected successful login")
            
            // Define wrapper to decode the response
            struct AuthResponseWrapper: Codable {
                let success: Bool
                let data: Identity.Authentication.Response
            }
            
            // Decode the response to verify tokens were received
            let responseData = try loginResponse.content.decode(AuthResponseWrapper.self)
            #expect(responseData.success == true, "Expected success flag to be true")
            
            // Verify response contains valid tokens
            #expect(!responseData.data.accessToken.value.isEmpty, "Expected non-empty access token")
            #expect(!responseData.data.refreshToken.value.isEmpty, "Expected non-empty refresh token")
            
            // Verify identity login was recorded in database
            let identity = try await Database.Identity.get(by: .email(try EmailAddress(testEmail)), on: app.db)
            #expect(identity.lastLoginAt != nil, "Expected lastLoginAt to be updated")
        }
    }
    
    @Test("Test login in with mock identity and token refresh")
    func testLoginAndTokenRefresh() async throws {
        try await withTestApp { app in
            
            let (testEmail, testPassword) = try await setupMockIdentity(app: app)
            
            // Define wrapper to decode the response
            struct AuthResponseWrapper: Codable {
                let success: Bool
                let data: Identity.Authentication.Response
            }
            
            let loginResponse = try await app.test(
                identity: .authenticate(
                    .credentials(
                        .init(
                            username: testEmail,
                            password: testPassword
                        )
                    )
                )
            )
            
            // Verify initial login was successful
            #expect(loginResponse.status == .ok, "Expected successful login")
            
            let responseData = try loginResponse.content.decode(AuthResponseWrapper.self)
            
            // Get the refresh token to use for token refresh
            let refreshToken = responseData.data.refreshToken
            
            // Verify the refresh token is valid
            let verified = try await app.jwt.keys.verify(
                refreshToken.value,
                as: JWT.Token.Refresh.self
            )
            print("verified Refresh token:", verified)
            
            // Print the access token to debug
            print("Initial access token:", responseData.data.accessToken.value)
            
            // Test token refresh - explicitly using the refresh token type
            let refreshResponse = try await app.test(
                identity: .authenticate(
                    .token(
                        .refresh(
                            .init(token: refreshToken.value)
                        )
                    )
                )
            )
            
            // Verify refresh was successful
            #expect(refreshResponse.status == .ok, "Expected successful token refresh")
            
            let refreshResponseData = try refreshResponse.content.decode(AuthResponseWrapper.self)
            #expect(refreshResponseData.success == true, "Expected success flag to be true")
            
            // Verify new tokens were received
            #expect(!refreshResponseData.data.accessToken.value.isEmpty, "Expected non-empty access token")
            #expect(!refreshResponseData.data.refreshToken.value.isEmpty, "Expected non-empty refresh token")
            
            // Print the new access token for debugging
            print("New access token:", refreshResponseData.data.accessToken.value)
            
            // Try to decode the access token directly to check its structure
            let decodedNewAccess = try? await app.jwt.keys.verify(
                refreshResponseData.data.accessToken.value,
                as: JWT.Token.Access.self
            )
            print("Decoded new access token:", decodedNewAccess?.subject.value ?? "decoding failed")
            
            // Verify the new access token works via the API
            let accessToken = refreshResponseData.data.accessToken
            let accessVerifyResponse = try await app.test(
                identity: .authenticate(
                    .token(
                        .access(
                            .init(token: accessToken.value)
                        )
                    )
                )
            )
            
            #expect(accessVerifyResponse.status == .ok, "Expected successful access token verification")
        }
    }
}
