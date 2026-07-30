//
//  Identity Router Tests Fixed.swift
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

extension Identity.Route {
    @Suite(.dependencies)
    struct Test {

        var router: AnyParserPrinter<RFC_3986.URI.Request.Data, Identity.Route> {
            @Dependency(\.identity) var identity
            return identity.router
        }

        @Test
        func `Creates correct URL for authenticate credentials`() throws {
            let api: Identity.API = .authenticate(
                .credentials(
                    .init(username: "user@example.com", password: "password123")
                )
            )

            let request = try router.request(for: .api(api))
            #expect(request.url?.path == "/api/authenticate")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.authenticate.api.credentials))
            #expect(
                Identity.Route.cases.authenticate.api.credentials.extract(match)?.username
                    == "user@example.com"
            )
            #expect(
                Identity.Route.cases.authenticate.api.credentials.extract(match)?.password
                    == "password123"
            )
        }

        @Test
        func `Creates correct URL for authenticate API key`() throws {
            let api: Identity.API = .authenticate(.apiKey(try .init(token: "test-api-key")))

            let request = try router.request(for: .api(api))
            #expect(request.url?.path == "/api/authenticate/api-key")

            let match = try router.match(request: request)
            #expect(match.is(\.authenticate.api.apiKey))
            #expect(
                Identity.Route.cases.authenticate.api.apiKey.extract(match)?.token == "test-api-key"
            )
        }

        @Test
        func `Creates correct URL for identity creation request`() throws {
            let api: Identity.API = .create(
                .request(
                    .init(email: "new@example.com", password: "password123")
                )
            )

            let request = try router.request(for: .api(api))
            #expect(request.url?.path == "/api/create/request")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.create.api.request))
            #expect(
                Identity.Route.cases.create.api.request.extract(match)?.email == "new@example.com"
            )
            #expect(
                Identity.Route.cases.create.api.request.extract(match)?.password == "password123"
            )
        }

        @Test
        func `Creates correct URL for identity creation verification`() throws {
            let api: Identity.API = .create(
                .verify(
                    .init(token: "verification-token", email: "verify@example.com")
                )
            )

            let request = try router.request(for: .api(api))
            #expect(request.url?.path == "/api/create/verify")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.create.api.verify))
            #expect(
                Identity.Route.cases.create.api.verify.extract(match)?.email == "verify@example.com"
            )
            #expect(
                Identity.Route.cases.create.api.verify.extract(match)?.token == "verification-token"
            )
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
            #expect(request.url?.path == "/api/password/reset/request")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.password.api.reset.request))
            #expect(
                Identity.Route.cases.password.api.reset.request.extract(match)?.email
                    == "reset@example.com"
            )
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
            #expect(request.url?.path == "/api/password/reset/confirm")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.password.api.reset.confirm))
            #expect(
                Identity.Route.cases.password.api.reset.confirm.extract(match)?.newPassword
                    == "newPassword123"
            )
            #expect(
                Identity.Route.cases.password.api.reset.confirm.extract(match)?.token
                    == "reset-token"
            )
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
            #expect(request.url?.path == "/api/password/change/request")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.password.api.change.request))
            #expect(
                Identity.Route.cases.password.api.change.request.extract(match)?.currentPassword
                    == "current123"
            )
            #expect(
                Identity.Route.cases.password.api.change.request.extract(match)?.newPassword
                    == "new123"
            )
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
            #expect(request.url?.path == "/api/email/request")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.email.api.change.request))
            #expect(
                Identity.Route.cases.email.api.change.request.extract(match)?.newEmail
                    == "newemail@example.com"
            )
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
            #expect(request.url?.path == "/api/email/confirm")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.email.api.change.confirm))
            #expect(
                Identity.Route.cases.email.api.change.confirm.extract(match)?.token
                    == "email-change-token"
            )
        }

        @Test
        func `Creates correct URL for delete request`() throws {
            let api: Identity.API = .delete(
                .request(
                    .init(reauthToken: "reauth-token-123")
                )
            )

            let request = try router.request(for: .api(api))
            #expect(request.url?.path == "/api/delete/request")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.delete.api.request))
            #expect(
                Identity.Route.cases.delete.api.request.extract(match)?.reauthToken
                    == "reauth-token-123"
            )
        }

        @Test
        func `Creates correct URL for delete confirmation`() throws {
            let api: Identity.API = .delete(.confirm)

            let request = try router.request(for: .api(api))
            #expect(request.url?.path == "/api/delete/confirm")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.delete.api.confirm))
        }

        @Test
        func `Creates correct URL for delete cancellation`() throws {
            let api: Identity.API = .delete(.cancel)

            let request = try router.request(for: .api(api))
            #expect(request.url?.path == "/api/delete/cancel")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.delete.api.cancel))
        }

        @Test
        func `Creates correct URL for logout current session`() throws {
            let api: Identity.API = .logout(.current)

            let request = try router.request(for: .api(api))
            #expect(request.url?.path == "/logout")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.logout.api.current))
        }

        @Test
        func `Creates correct URL for logout all sessions`() throws {
            let api: Identity.API = .logout(.all)

            let request = try router.request(for: .api(api))
            #expect(request.url?.path == "/logout/all")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.logout.api.all))
        }

        @Test
        func `Creates correct URL for reauthorization`() throws {
            let api: Identity.API = .reauthorize(
                .init(password: "password123")
            )

            let request = try router.request(for: .api(api))
            #expect(request.url?.path == "/api/reauthorize")
            #expect(request.httpMethod == "POST")

            let match = try router.match(request: request)
            #expect(match.is(\.reauthorize.api))
            #expect(Identity.Route.cases.reauthorize.api.extract(match)?.password == "password123")
        }
    }
}
