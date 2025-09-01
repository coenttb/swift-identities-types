//
//  Identity Router Tests Fixed.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 20/02/2025.
//

import Authenticating
import Dependencies
import DependenciesTestSupport
import EmailAddress
import Foundation
@testable import Identities
import Testing
import URLRouting

@Suite("Identity API Router Tests")
struct IdentityAPIRouterTests {
    
    let router: Identity.API.Router = .init()
    
    @Test("Creates correct URL for authenticate credentials")
    func testAuthenticateCredentialsURL() throws {
        let api: Identity.API = .authenticate(.credentials(
            .init(username: "user@example.com", password: "password123")
        ))
        
        let request = try router.request(for: api)
        #expect(request.url?.path == "/authenticate")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.authenticate.credentials))
        #expect(match.authenticate?.credentials?.username == "user@example.com")
        #expect(match.authenticate?.credentials?.password == "password123")
    }
    
    @Test("Creates correct URL for authenticate API key")
    func testAuthenticateAPIKeyURL() throws {
        let api: Identity.API = .authenticate(.apiKey(try .init(token: "test-api-key")))
        
        let request = try router.request(for: api)
        #expect(request.url?.path == "/authenticate/api-key")
        
        let match = try router.match(request: request)
        #expect(match.is(\.authenticate.apiKey))
        #expect(match.authenticate?.apiKey?.token == "test-api-key")
    }
    
    @Test("Creates correct URL for identity creation request")
    func testCreateRequestURL() throws {
        let api: Identity.API = .create(.request(
            .init(email: "new@example.com", password: "password123")
        ))
        
        let request = try router.request(for: api)
        #expect(request.url?.path == "/create/request")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.create.request))
        #expect(match.create?.request?.email == "new@example.com")
        #expect(match.create?.request?.password == "password123")
    }
    
    @Test("Creates correct URL for identity creation verification")
    func testCreateVerificationURL() throws {
        let api: Identity.API = .create(.verify(
            .init(token: "verification-token", email: "verify@example.com")
        ))
        
        let request = try router.request(for: api)
        #expect(request.url?.path == "/create/verify")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.create.verify))
        #expect(match.create?.verify?.email == "verify@example.com")
        #expect(match.create?.verify?.token == "verification-token")
    }
    
    @Test("Creates correct URL for password reset request")
    func testPasswordResetRequestURL() throws {
        let api: Identity.API = .password(.reset(.request(
            .init(email: "reset@example.com")
        )))
        
        let request = try router.request(for: api)
        #expect(request.url?.path == "/password/reset/request")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.password.reset.request))
        #expect(match.password?.reset?.request?.email == "reset@example.com")
    }
    
    @Test("Creates correct URL for password reset confirmation")
    func testPasswordResetConfirmURL() throws {
        let api: Identity.API = .password(.reset(.confirm(
            .init(token: "reset-token", newPassword: "newPassword123")
        )))
        
        let request = try router.request(for: api)
        #expect(request.url?.path == "/password/reset/confirm")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.password.reset.confirm))
        #expect(match.password?.reset?.confirm?.newPassword == "newPassword123")
        #expect(match.password?.reset?.confirm?.token == "reset-token")
    }
    
    @Test("Creates correct URL for password change request")
    func testPasswordChangeRequestURL() throws {
        let api: Identity.API = .password(.change(.request(
            change: .init(currentPassword: "current123", newPassword: "new123")
        )))
        
        let request = try router.request(for: api)
        #expect(request.url?.path == "/password/change/request")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.password.change.request))
        #expect(match.password?.change?.request?.currentPassword == "current123")
        #expect(match.password?.change?.request?.newPassword == "new123")
    }
    
    @Test("Creates correct URL for email change request")
    func testEmailChangeRequestURL() throws {
        let api: Identity.API = .email(.change(.request(
            .init(newEmail: "newemail@example.com")
        )))
        
        let request = try router.request(for: api)
        #expect(request.url?.path == "/email/request")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.email.change.request))
        #expect(match.email?.change?.request?.newEmail == "newemail@example.com")
    }
    
    @Test("Creates correct URL for email change confirmation")
    func testEmailChangeConfirmURL() throws {
        let api: Identity.API = .email(.change(.confirm(
            .init(token: "email-change-token")
        )))
        
        let request = try router.request(for: api)
        #expect(request.url?.path == "/email/confirm")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.email.change.confirm))
        #expect(match.email?.change?.confirm?.token == "email-change-token")
    }
    
    @Test("Creates correct URL for delete request")
    func testDeleteRequestURL() throws {
        let api: Identity.API = .delete(.request(
            .init(reauthToken: "reauth-token-123")
        ))
        
        let request = try router.request(for: api)
        #expect(request.url?.path == "/delete/request")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.delete.request))
        #expect(match.delete?.request?.reauthToken == "reauth-token-123")
    }
    
    @Test("Creates correct URL for delete confirmation")
    func testDeleteConfirmURL() throws {
        let api: Identity.API = .delete(.confirm)
        
        let request = try router.request(for: api)
        #expect(request.url?.path == "/delete/confirm")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.delete.confirm))
    }
    
    @Test("Creates correct URL for delete cancellation")
    func testDeleteCancelURL() throws {
        let api: Identity.API = .delete(.cancel)
        
        let request = try router.request(for: api)
        #expect(request.url?.path == "/delete/cancel")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.delete.cancel))
    }
    
    @Test("Creates correct URL for logout current session")
    func testLogoutCurrentURL() throws {
        let api: Identity.API = .logout(.current)
        
        let request = try router.request(for: api)
        #expect(request.url?.path == "/logout")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.logout.current))
    }
    
    @Test("Creates correct URL for logout all sessions")
    func testLogoutAllURL() throws {
        let api: Identity.API = .logout(.all)
        
        let request = try router.request(for: api)
        #expect(request.url?.path == "/logout/all")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.logout.all))
    }
    
    @Test("Creates correct URL for reauthorization")
    func testReauthorizeURL() throws {
        let api: Identity.API = .reauthorize(
            .init(password: "password123")
        )
        
        let request = try router.request(for: api)
        #expect(request.url?.path == "/reauthorize")
        #expect(request.httpMethod == "POST")
        
        let match = try router.match(request: request)
        #expect(match.is(\.reauthorize))
        #expect(match.reauthorize?.password == "password123")
    }
}