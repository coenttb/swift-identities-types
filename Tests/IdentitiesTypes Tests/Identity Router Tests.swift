//
//  Identity Router Tests Fixed.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 20/02/2025.
//

import Dependencies
import Dependencies_Test_Support
import EmailAddress
import Testing

@testable import IdentitiesTypes

extension Identity.Route {
    @Suite(.dependencies)
    struct Test {

        let router = Identity.Route.self

        @Test
        func `Creates correct URL for authenticate credentials`() throws {
            let api: Identity.API = .authenticate(
                .credentials(
                    .init(username: "user@example.com", password: "password123")
                )
            )

            let request = try router.request(for: .api(api))
            #expect(request.path == "/api/authenticate")
            #expect(request.method.rawValue == "POST")

            let match = try router.match(request: request)
            #expect({ if case .authenticate(.api(.credentials)) = match { true } else { false } }())
            if case .authenticate(.api(.credentials(let value))) = match {
                #expect(value.username == "user@example.com")
            } else {
                Issue.record("expected authenticate.api.credentials, got \(match)")
            }
            if case .authenticate(.api(.credentials(let value))) = match {
                #expect(value.password == "password123")
            } else {
                Issue.record("expected authenticate.api.credentials, got \(match)")
            }
        }

        @Test
        func `Creates correct URL for authenticate API key`() throws {
            let api: Identity.API = .authenticate(.apiKey(try .init(token: "test-api-key")))

            let request = try router.request(for: .api(api))
            #expect(request.path == "/api/authenticate/api-key")

            let match = try router.match(request: request)
            #expect({ if case .authenticate(.api(.apiKey)) = match { true } else { false } }())
            if case .authenticate(.api(.apiKey(let value))) = match {
                #expect(value.token == "test-api-key")
            } else {
                Issue.record("expected authenticate.api.apiKey, got \(match)")
            }
        }

        @Test
        func `Creates correct URL for identity creation request`() throws {
            let api: Identity.API = .create(
                .request(
                    .init(email: "new@example.com", password: "password123")
                )
            )

            let request = try router.request(for: .api(api))
            #expect(request.path == "/api/create/request")
            #expect(request.method.rawValue == "POST")

            let match = try router.match(request: request)
            #expect({ if case .create(.api(.request)) = match { true } else { false } }())
            if case .create(.api(.request(let value))) = match {
                #expect(value.email == "new@example.com")
            } else {
                Issue.record("expected create.api.request, got \(match)")
            }
            if case .create(.api(.request(let value))) = match {
                #expect(value.password == "password123")
            } else {
                Issue.record("expected create.api.request, got \(match)")
            }
        }

        @Test
        func `Creates correct URL for identity creation verification`() throws {
            let api: Identity.API = .create(
                .verify(
                    .init(token: "verification-token", email: "verify@example.com")
                )
            )

            let request = try router.request(for: .api(api))
            #expect(request.path == "/api/create/verify")
            #expect(request.method.rawValue == "POST")

            let match = try router.match(request: request)
            #expect({ if case .create(.api(.verify)) = match { true } else { false } }())
            if case .create(.api(.verify(let value))) = match {
                #expect(value.email == "verify@example.com")
            } else {
                Issue.record("expected create.api.verify, got \(match)")
            }
            if case .create(.api(.verify(let value))) = match {
                #expect(value.token == "verification-token")
            } else {
                Issue.record("expected create.api.verify, got \(match)")
            }
        }

        @Test
        func `Creates correct URL for password reset request`() throws {
            let api: Identity.API = .password(
                .reset(
                    .request(
                        .init(email: "reset@example.com")
                    )
                )
            )

            let request = try router.request(for: .api(api))
            #expect(request.path == "/api/password/reset/request")
            #expect(request.method.rawValue == "POST")

            let match = try router.match(request: request)
            #expect({ if case .password(.api(.reset(.request))) = match { true } else { false } }())
            if case .password(.api(.reset(.request(let value)))) = match {
                #expect(value.email == "reset@example.com")
            } else {
                Issue.record("expected password.api.reset.request, got \(match)")
            }
        }

        @Test
        func `Creates correct URL for password reset confirmation`() throws {
            let api: Identity.API = .password(
                .reset(
                    .confirm(
                        .init(token: "reset-token", newPassword: "newPassword123")
                    )
                )
            )

            let request = try router.request(for: .api(api))
            #expect(request.path == "/api/password/reset/confirm")
            #expect(request.method.rawValue == "POST")

            let match = try router.match(request: request)
            #expect({ if case .password(.api(.reset(.confirm))) = match { true } else { false } }())
            if case .password(.api(.reset(.confirm(let value)))) = match {
                #expect(value.newPassword == "newPassword123")
            } else {
                Issue.record("expected password.api.reset.confirm, got \(match)")
            }
            if case .password(.api(.reset(.confirm(let value)))) = match {
                #expect(value.token == "reset-token")
            } else {
                Issue.record("expected password.api.reset.confirm, got \(match)")
            }
        }

        @Test
        func `Creates correct URL for password change request`() throws {
            let api: Identity.API = .password(
                .change(
                    .request(
                        .init(currentPassword: "current123", newPassword: "new123")
                    )
                )
            )

            let request = try router.request(for: .api(api))
            #expect(request.path == "/api/password/change/request")
            #expect(request.method.rawValue == "POST")

            let match = try router.match(request: request)
            #expect(
                { if case .password(.api(.change(.request))) = match { true } else { false } }()
            )
            if case .password(.api(.change(.request(let value)))) = match {
                #expect(value.currentPassword == "current123")
            } else {
                Issue.record("expected password.api.change.request, got \(match)")
            }
            if case .password(.api(.change(.request(let value)))) = match {
                #expect(value.newPassword == "new123")
            } else {
                Issue.record("expected password.api.change.request, got \(match)")
            }
        }

        @Test
        func `Creates correct URL for email change request`() throws {
            let api: Identity.API = .email(
                .change(
                    .request(
                        .init(newEmail: "newemail@example.com")
                    )
                )
            )

            let request = try router.request(for: .api(api))
            #expect(request.path == "/api/email/request")
            #expect(request.method.rawValue == "POST")

            let match = try router.match(request: request)
            #expect({ if case .email(.api(.change(.request))) = match { true } else { false } }())
            if case .email(.api(.change(.request(let value)))) = match {
                #expect(value.newEmail == "newemail@example.com")
            } else {
                Issue.record("expected email.api.change.request, got \(match)")
            }
        }

        @Test
        func `Creates correct URL for email change confirmation`() throws {
            let api: Identity.API = .email(
                .change(
                    .confirm(
                        .init(token: "email-change-token")
                    )
                )
            )

            let request = try router.request(for: .api(api))
            #expect(request.path == "/api/email/confirm")
            #expect(request.method.rawValue == "POST")

            let match = try router.match(request: request)
            #expect({ if case .email(.api(.change(.confirm))) = match { true } else { false } }())
            if case .email(.api(.change(.confirm(let value)))) = match {
                #expect(value.token == "email-change-token")
            } else {
                Issue.record("expected email.api.change.confirm, got \(match)")
            }
        }

        @Test
        func `Creates correct URL for delete request`() throws {
            let api: Identity.API = .delete(
                .request(
                    .init(reauthToken: "reauth-token-123")
                )
            )

            let request = try router.request(for: .api(api))
            #expect(request.path == "/api/delete/request")
            #expect(request.method.rawValue == "POST")

            let match = try router.match(request: request)
            #expect({ if case .delete(.api(.request)) = match { true } else { false } }())
            if case .delete(.api(.request(let value))) = match {
                #expect(value.reauthToken == "reauth-token-123")
            } else {
                Issue.record("expected delete.api.request, got \(match)")
            }
        }

        @Test
        func `Creates correct URL for delete confirmation`() throws {
            let api: Identity.API = .delete(.confirm)

            let request = try router.request(for: .api(api))
            #expect(request.path == "/api/delete/confirm")
            #expect(request.method.rawValue == "POST")

            let match = try router.match(request: request)
            #expect({ if case .delete(.api(.confirm)) = match { true } else { false } }())
        }

        @Test
        func `Creates correct URL for delete cancellation`() throws {
            let api: Identity.API = .delete(.cancel)

            let request = try router.request(for: .api(api))
            #expect(request.path == "/api/delete/cancel")
            #expect(request.method.rawValue == "POST")

            let match = try router.match(request: request)
            #expect({ if case .delete(.api(.cancel)) = match { true } else { false } }())
        }

        @Test
        func `Creates correct URL for logout current session`() throws {
            let api: Identity.API = .logout(.current)

            let request = try router.request(for: .api(api))
            #expect(request.path == "/logout")
            #expect(request.method.rawValue == "POST")

            let match = try router.match(request: request)
            #expect({ if case .logout(.api(.current)) = match { true } else { false } }())
        }

        @Test
        func `Creates correct URL for logout all sessions`() throws {
            let api: Identity.API = .logout(.all)

            let request = try router.request(for: .api(api))
            #expect(request.path == "/logout/all")
            #expect(request.method.rawValue == "POST")

            let match = try router.match(request: request)
            #expect({ if case .logout(.api(.all)) = match { true } else { false } }())
        }

        @Test
        func `Creates correct URL for reauthorization`() throws {
            let api: Identity.API = .reauthorize(
                .init(password: "password123")
            )

            let request = try router.request(for: .api(api))
            #expect(request.path == "/api/reauthorize")
            #expect(request.method.rawValue == "POST")

            let match = try router.match(request: request)
            #expect({ if case .reauthorize(.api) = match { true } else { false } }())
            if case .reauthorize(.api(let value)) = match {
                #expect(value.password == "password123")
            } else {
                Issue.record("expected reauthorize.api, got \(match)")
            }
        }
    }
}
