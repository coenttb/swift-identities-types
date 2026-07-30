//
//  Identity Route Parity Tests.swift
//  swift-identities-types
//
//  Batch-0 wire-shape parity corpus: every body route constructible with
//  deterministic fixed values, plus representative GET/view routes per area.
//  All routes print through the fully composed `Identity.Route.Router()`;
//  the standalone `Identity.API.Router()` / `Identity.View.Router()` facades
//  have their own corpora.
//

import Foundation
import IdentitiesTypes
import Testing
import URL_Routing_Test_Support

// Deterministic fixtures (no Date()/UUID(); single-entry collections only).
enum Fixtures {
    /// {"alg":"none"} . {"sub":"parity"} . bytes 01 02 03
    static let jwtCompact = "eyJhbGciOiJub25lIn0.eyJzdWIiOiJwYXJpdHkifQ.AQID"
    static var jwt: JWT {
        // Fixed, valid compact-JWT literal above — never throws.
        // swiftlint:disable:next force_try
        try! JWT.parse(from: jwtCompact)
    }
    static var bearer: RFC_6750.Bearer {
        // Fixed, valid token literal — never throws.
        // swiftlint:disable:next force_try
        RFC_6750.Bearer(b64token: try! .init("parity-token-123"))
    }
    static let router = Identity.Route.Router()
}

@Suite("Identity Route Parity")
struct IdentityRouteParity {

    func assertCorpus(
        _ routes: [(name: String, route: Identity.Route)],
        fixture: String
    ) throws {
        try assertParity(try Parity.corpus(of: routes, via: Fixtures.router), fixture: fixture)
        for (name, route) in routes {
            #expect(try Parity.roundTrips(route, via: Fixtures.router), "\(name)")
        }
    }

    @Test func authentication() throws {
        let routes: [(name: String, route: Identity.Route)] = [
            (
                "api.credentials",
                .authenticate(
                    .api(.credentials(.init(username: "user@example.com", password: "secret1234")))
                )
            ),
            ("api.token.access", .authenticate(.api(.token(.access(Fixtures.jwt))))),
            ("api.token.refresh", .authenticate(.api(.token(.refresh(Fixtures.jwt))))),
            ("api.apiKey", .authenticate(.api(.apiKey(Fixtures.bearer)))),
            ("view.credentials", .authenticate(.view(.credentials))),
        ]
        try assertCorpus(routes, fixture: "Authentication")
    }

    @Test func creation() throws {
        let routes: [(name: String, route: Identity.Route)] = [
            (
                "api.request",
                .create(.api(.request(.init(email: "user@example.com", password: "secret1234"))))
            ),
            (
                "api.verify",
                .create(.api(.verify(.init(token: "verify-token-123", email: "user@example.com"))))
            ),
            ("view.request", .create(.view(.request))),
            (
                "view.verify",
                .create(.view(.verify(.init(token: "verify-token-123", email: "user@example.com"))))
            ),
        ]
        try assertCorpus(routes, fixture: "Creation")
    }

    @Test func deletion() throws {
        let routes: [(name: String, route: Identity.Route)] = [
            ("api.request", .delete(.api(.request(.init(reauthToken: "reauth-token-123"))))),
            ("api.cancel", .delete(.api(.cancel))),
            ("api.confirm", .delete(.api(.confirm))),
            ("view.request", .delete(.view(.request))),
        ]
        try assertCorpus(routes, fixture: "Deletion")
    }

    @Test func logout() throws {
        let routes: [(name: String, route: Identity.Route)] = [
            ("api.current", .logout(.api(.current))),
            ("api.all", .logout(.api(.all))),
            ("view", .logout(.view)),
        ]
        try assertCorpus(routes, fixture: "Logout")
    }

    @Test func reauthorization() throws {
        let routes: [(name: String, route: Identity.Route)] = [
            ("api.request", .reauthorize(.api(.init(password: "secret1234"))))
        ]
        try assertCorpus(routes, fixture: "Reauthorization")
    }

    @Test func email() throws {
        let routes: [(name: String, route: Identity.Route)] = [
            (
                "api.change.request",
                .email(.api(.change(.request(.init(newEmail: "new@example.com")))))
            ),
            (
                "api.change.confirm",
                .email(.api(.change(.confirm(.init(token: "email-token-123")))))
            ),
            ("view.change.request", .email(.view(.change(.request)))),
            (
                "view.change.confirm",
                .email(.view(.change(.confirm(.init(token: "email-token-123")))))
            ),
            ("view.change.reauthorization", .email(.view(.change(.reauthorization)))),
        ]
        try assertCorpus(routes, fixture: "Email")
    }

    @Test func password() throws {
        let routes: [(name: String, route: Identity.Route)] = [
            (
                "api.reset.request",
                .password(.api(.reset(.request(.init(email: "user@example.com")))))
            ),
            (
                "api.reset.confirm",
                .password(
                    .api(
                        .reset(.confirm(.init(token: "reset-token-123", newPassword: "newSecret1")))
                    )
                )
            ),
            (
                "api.change.request",
                .password(
                    .api(
                        .change(
                            .request(
                                .init(currentPassword: "secret1234", newPassword: "newSecret1")
                            )
                        )
                    )
                )
            ),
            ("view.reset.request", .password(.view(.reset(.request)))),
            (
                "view.reset.confirm",
                .password(
                    .view(
                        .reset(.confirm(.init(token: "reset-token-123", newPassword: "newSecret1")))
                    )
                )
            ),
            ("view.change.request", .password(.view(.change(.request)))),
        ]
        try assertCorpus(routes, fixture: "Password")
    }

    @Test func mfa() throws {
        let routes: [(name: String, route: Identity.Route)] = [
            // TOTP
            ("api.totp.setup", .mfa(.api(.totp(.setup)))),
            ("api.totp.confirmSetup", .mfa(.api(.totp(.confirmSetup(.init(code: "123456")))))),
            (
                "api.totp.verify",
                .mfa(.api(.totp(.verify(.init(code: "123456", sessionToken: "session-token-123")))))
            ),
            (
                "api.totp.disable",
                .mfa(.api(.totp(.disable(.init(reauthorizationToken: "reauth-token-123")))))
            ),
            // SMS
            ("api.sms.setup", .mfa(.api(.sms(.setup(.init(phoneNumber: "+15555550100")))))),
            ("api.sms.requestCode", .mfa(.api(.sms(.requestCode)))),
            (
                "api.sms.verify",
                .mfa(.api(.sms(.verify(.init(code: "123456", sessionToken: "session-token-123")))))
            ),
            (
                "api.sms.updatePhoneNumber",
                .mfa(
                    .api(
                        .sms(
                            .updatePhoneNumber(
                                .init(
                                    phoneNumber: "+15555550101",
                                    reauthorizationToken: "reauth-token-123"
                                )
                            )
                        )
                    )
                )
            ),
            (
                "api.sms.disable",
                .mfa(.api(.sms(.disable(.init(reauthorizationToken: "reauth-token-123")))))
            ),
            // Email
            ("api.email.setup", .mfa(.api(.email(.setup(.init(email: "mfa@example.com")))))),
            ("api.email.requestCode", .mfa(.api(.email(.requestCode)))),
            (
                "api.email.verify",
                .mfa(
                    .api(.email(.verify(.init(code: "123456", sessionToken: "session-token-123"))))
                )
            ),
            (
                "api.email.updateEmail",
                .mfa(
                    .api(
                        .email(
                            .updateEmail(
                                .init(
                                    email: "mfa2@example.com",
                                    reauthorizationToken: "reauth-token-123"
                                )
                            )
                        )
                    )
                )
            ),
            (
                "api.email.disable",
                .mfa(.api(.email(.disable(.init(reauthorizationToken: "reauth-token-123")))))
            ),
            // WebAuthn
            ("api.webauthn.beginRegistration", .mfa(.api(.webauthn(.beginRegistration)))),
            (
                "api.webauthn.finishRegistration",
                .mfa(
                    .api(
                        .webauthn(
                            .finishRegistration(
                                .init(
                                    credentialName: "parity-key",
                                    response: "attestation-response"
                                )
                            )
                        )
                    )
                )
            ),
            ("api.webauthn.beginAuthentication", .mfa(.api(.webauthn(.beginAuthentication)))),
            (
                "api.webauthn.finishAuthentication",
                .mfa(
                    .api(
                        .webauthn(
                            .finishAuthentication(
                                .init(
                                    response: "assertion-response",
                                    sessionToken: "session-token-123"
                                )
                            )
                        )
                    )
                )
            ),
            ("api.webauthn.listCredentials", .mfa(.api(.webauthn(.listCredentials)))),
            (
                "api.webauthn.removeCredential",
                .mfa(
                    .api(
                        .webauthn(
                            .removeCredential(
                                .init(
                                    credentialId: "credential-123",
                                    reauthorizationToken: "reauth-token-123"
                                )
                            )
                        )
                    )
                )
            ),
            (
                "api.webauthn.disable",
                .mfa(.api(.webauthn(.disable(.init(reauthorizationToken: "reauth-token-123")))))
            ),
            // Backup codes
            ("api.backupCodes.regenerate", .mfa(.api(.backupCodes(.regenerate)))),
            (
                "api.backupCodes.verify",
                .mfa(
                    .api(
                        .backupCodes(
                            .verify(.init(code: "backup-code-1", sessionToken: "session-token-123"))
                        )
                    )
                )
            ),
            ("api.backupCodes.remaining", .mfa(.api(.backupCodes(.remaining)))),
            // Status
            ("api.status.get", .mfa(.api(.status(.get)))),
            ("api.status.challenge", .mfa(.api(.status(.challenge)))),
            // Top-level verify (form body)
            (
                "api.verify",
                .mfa(
                    .api(
                        .verify(
                            .init(sessionToken: "session-token-123", method: .totp, code: "123456")
                        )
                    )
                )
            ),
            // Views
            (
                "view.verify",
                .mfa(.view(.verify(.init(sessionToken: "session-token-123", attemptsRemaining: 3))))
            ),
            ("view.manage", .mfa(.view(.manage))),
            ("view.totp.setup", .mfa(.view(.totp(.setup)))),
            ("view.totp.confirmSetup", .mfa(.view(.totp(.confirmSetup)))),
            ("view.totp.manage", .mfa(.view(.totp(.manage)))),
            ("view.backupCodes.display", .mfa(.view(.backupCodes(.display)))),
            (
                "view.backupCodes.verify",
                .mfa(
                    .view(
                        .backupCodes(
                            .verify(.init(sessionToken: "session-token-123", attemptsRemaining: 3))
                        )
                    )
                )
            ),
        ]
        try assertCorpus(routes, fixture: "MFA")
    }

    @Test func oauth() throws {
        let routes: [(name: String, route: Identity.Route)] = [
            ("api.providers", .oauth(.api(.providers))),
            ("api.authorize", .oauth(.api(.authorize(provider: "github")))),
            (
                "api.callback",
                .oauth(
                    .api(
                        .callback(
                            .init(
                                provider: "github",
                                code: "oauth-code-123",
                                state: "oauth-state-123",
                                redirectURI: nil
                            )
                        )
                    )
                )
            ),
            ("api.connections", .oauth(.api(.connections))),
            ("api.disconnect", .oauth(.api(.disconnect(provider: "github")))),
            ("view.login", .oauth(.view(.login))),
            (
                "view.callback",
                .oauth(
                    .view(
                        .callback(
                            .init(
                                provider: "github",
                                code: "oauth-code-123",
                                state: "oauth-state-123",
                                redirectURI: nil
                            )
                        )
                    )
                )
            ),
            ("view.connections", .oauth(.view(.connections))),
            ("view.error", .oauth(.view(.error("parity-error")))),
        ]
        try assertCorpus(routes, fixture: "OAuth")
    }
}

@Suite("Identity Facade Parity")
struct IdentityFacadeParity {

    /// The standalone `Identity.API.Router()` facade (no /api prefix).
    @Test func api() throws {
        let router = Identity.API.Router()
        let routes: [(name: String, route: Identity.API)] = [
            (
                "authenticate.credentials",
                .authenticate(
                    .credentials(.init(username: "user@example.com", password: "secret1234"))
                )
            ),
            ("reauthorize", .reauthorize(.init(password: "secret1234"))),
            (
                "create.request",
                .create(.request(.init(email: "user@example.com", password: "secret1234")))
            ),
            ("delete.cancel", .delete(.cancel)),
            ("logout.current", .logout(.current)),
            ("email.change.request", .email(.change(.request(.init(newEmail: "new@example.com"))))),
            (
                "password.reset.request",
                .password(.reset(.request(.init(email: "user@example.com"))))
            ),
            ("mfa.status.get", .mfa(.status(.get))),
            ("oauth.providers", .oauth(.providers)),
        ]
        try assertParity(try Parity.corpus(of: routes, via: router), fixture: "Facade API")
        for (name, route) in routes {
            #expect(try Parity.roundTrips(route, via: router), "\(name)")
        }
    }

    /// The standalone `Identity.View.Router()` facade.
    @Test func view() throws {
        let router = Identity.View.Router()
        let routes: [(name: String, route: Identity.View)] = [
            ("authenticate.credentials", .authenticate(.credentials)),
            ("create.request", .create(.request)),
            ("delete.request", .delete(.request)),
            ("logout", .logout),
            ("email.change.request", .email(.change(.request))),
            ("password.reset.request", .password(.reset(.request))),
            ("mfa.manage", .mfa(.manage)),
            ("oauth.login", .oauth(.login)),
        ]
        try assertParity(try Parity.corpus(of: routes, via: router), fixture: "Facade View")
        for (name, route) in routes {
            #expect(try Parity.roundTrips(route, via: router), "\(name)")
        }
    }
}
