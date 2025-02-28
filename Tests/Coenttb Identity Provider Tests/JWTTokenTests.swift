//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 28/02/2025.
//

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

@Suite("JWT Token Tests")
struct JWTTokenTests {
    @Test("JWT Token Access should encode both identity ID and email in subject")
    func testAccessTokenSubjectFormat() async throws {
        // Create test identity ID and email address
        let testIdentityId = UUID()
        let testEmail = try EmailAddress("test@example.com")
        
        // Create a JWT Access token directly
        let accessToken = JWT.Token.Access(
            expiration: .init(value: Date().addingTimeInterval(3600)),
            issuedAt: .init(value: Date()),
            identityId: testIdentityId,
            email: testEmail
        )
        
        // Check that subject contains both ID and email in correct format
        let subjectComponents = accessToken.subject.value.components(separatedBy: ":")
        #expect(subjectComponents.count == 2, "Subject should contain both ID and email separated by ':'")
        #expect(subjectComponents[0] == testIdentityId.uuidString, "First part of subject should be identity ID")
        #expect(subjectComponents[1] == testEmail.rawValue, "Second part of subject should be email")
        
        // Verify accessors work correctly
        #expect(accessToken.identityId == testIdentityId, "identityId accessor should return correct ID")
        #expect(accessToken.emailAddress == testEmail, "email accessor should return correct email")
        
        // Test the setters also work correctly
        let newIdentityId = UUID()
        let newEmail = try EmailAddress("new@example.com")
        
        var mutableToken = accessToken
        mutableToken.identityId = newIdentityId
        mutableToken.emailAddress = newEmail
        
        #expect(mutableToken.identityId == newIdentityId, "identityId setter should update correctly")
        #expect(mutableToken.emailAddress == newEmail, "email setter should update correctly")
        
        // Verify the subject was updated with both values
        let updatedComponents = mutableToken.subject.value.components(separatedBy: ":")
        #expect(updatedComponents.count == 2, "Updated subject should maintain format")
        #expect(updatedComponents[0] == newIdentityId.uuidString, "First part should be updated ID")
        #expect(updatedComponents[1] == newEmail.rawValue, "Second part should be updated email")
    }
    
    @Test("JWT token encoding and decoding should preserve subject format with email")
    func testTokenEncodingDecoding() async throws {
        try await withTestApp { app in
            // 1. Create an access token with identity ID and email
            let identityId = UUID()
            let email = try EmailAddress("encode-test@example.com")
            
            let accessToken = JWT.Token.Access(
                expiration: .init(value: Date().addingTimeInterval(3600)),
                issuedAt: .init(value: Date()),
                identityId: identityId,
                email: email
            )
            
            // 2. Encode the token to a string
            let encodedToken = try await app.jwt.keys.sign(accessToken)
            print("Original token subject:", accessToken.subject.value)
            
            // 3. Decode the token back
            let decodedToken = try await app.jwt.keys.verify(encodedToken, as: JWT.Token.Access.self)
            print("Decoded token subject:", decodedToken.subject.value)
            
            // 4. Verify the subject format is preserved
            let components = decodedToken.subject.value.components(separatedBy: ":")
            #expect(components.count == 2, "Subject should contain both ID and email separated by ':' after decode")
            #expect(components[0] == identityId.uuidString, "First part should be identity ID after decode")
            #expect(components[1] == email.rawValue, "Second part should be email after decode")
            
            // 5. Verify accessors work on decoded token
            #expect(decodedToken.identityId == identityId, "identityId should be preserved")
            #expect(decodedToken.emailAddress == email, "emailAddress should be preserved")
        }
    }
    
//    @Test("JWT Token Access created from Database.Identity should include email in subject")
//    func testAccessTokenFromDatabaseIdentity() async throws {
//        try await withTestApp { app in
//            // Create and verify a test identity
//            let testEmail = "jwt-test@example.com"
//            let testPassword = "securePassword123!"
//
//            // Create the identity directly in the database
//            let identity = Database.Identity.init(
//                email: try EmailAddress(testEmail),
//                passwordHash: try Bcrypt.hash(testPassword)
//            )
//            try await identity.save(on: app.db)
//
//            // Verify identity was created with proper email
//            let savedIdentity = try await Database.Identity.get(by: .email(try EmailAddress(testEmail)), on: app.db)
//            #expect(savedIdentity.emailAddress == try EmailAddress(testEmail))
//
//            // Generate tokens using the database identity method
//            prepareDependencies {
//                $0.application = app
//                $0.date = .init { Date() }
//                $0.identity.provider.cookies.accessToken = .init(
//                    name: "test_access",
//                    expires: 900,
//                    secure: false,
//                    httpOnly: true,
//                    sameSite: .lax
//                )
//            }
//
//            // Generated access token string
//            let accessTokenString = try await savedIdentity.generateJWTAccess()
//
//            // Verify the token
//            let accessToken = try await app.jwt.keys.verify(accessTokenString, as: JWT.Token.Access.self)
//
//            // Print the subject for debugging
//            print("DB Identity subject value:", accessToken.subject.value)
//
//            // Check subject components
//            let subjectComponents = accessToken.subject.value.components(separatedBy: ":")
//            #expect(subjectComponents.count == 2, "Subject should contain both ID and email separated by ':'")
//            #expect(subjectComponents[0] == savedIdentity.id?.uuidString, "First part of subject should be identity ID")
//            #expect(subjectComponents[1] == testEmail, "Second part of subject should be email")
//
//            // Validate accessors work
//            #expect(accessToken.identityId == savedIdentity.id, "identityId accessor should return correct ID")
//            #expect(accessToken.email.rawValue == testEmail, "email accessor should return correct email")
//        }
//    }
}
