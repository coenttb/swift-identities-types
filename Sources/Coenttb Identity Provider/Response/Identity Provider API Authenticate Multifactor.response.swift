//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2024.
//

import Coenttb_Vapor
import Coenttb_Web
import Foundation
import Identity_Provider

extension Identity.Provider.API.Authenticate.Multifactor {
    package static func response(
        multifactor: Identity.Provider.API.Authenticate.Multifactor,
        logoutRedirectURL: () -> URL
    ) async throws -> any AsyncResponseEncodable {

        @Dependency(Identity.Provider.Client.self) var client

        guard let mfa = client.authenticate.multifactor
        else { throw Abort(.notImplemented, reason: "Multi-factor authentication is not supported") }

        switch multifactor {
        case .setup(let setup):
            switch setup {
            case .initialize(let request):
                do {
                    let data = try await mfa.setup.initialize(request.method, request.identifier)
                    return Response.success(true, data: data)
                } catch {
                    throw Abort(.internalServerError, reason: "Failed to initialize MFA setup")
                }

            case .confirm(let confirm):
                do {
                    try await mfa.setup.confirm(confirm.code)
                    return Response.success(true)
                } catch {
                    throw Abort(.internalServerError, reason: "Failed to confirm MFA setup")
                }
            }

        case .challenge(let challenge):
            switch challenge {
            case .create(let request):
                do {
                    let challenge = try await mfa.verification.createChallenge(request.method)
                    return Response.success(true, data: challenge)
                } catch {
                    throw Abort(.internalServerError, reason: "Failed to create MFA challenge")
                }
            }

        case .verify(let verify):
            switch verify {
            case .verify(let verification):
                do {
                    try await mfa.verification.verify(verification.challengeId, verification.code)
                    return Response.success(true)
                } catch {
                    throw Abort(.internalServerError, reason: "Failed to verify MFA code")
                }
            }

        case .recovery(let recovery):
            switch recovery {
            case .generate:
                do {
                    let codes = try await mfa.recovery.generateNewCodes()
                    return Response.success(true, data: codes)
                } catch {
                    throw Abort(.internalServerError, reason: "Failed to generate recovery codes")
                }

            case .count:
                do {
                    let count = try await mfa.recovery.getRemainingCodeCount()
                    return Response.success(true, data: count)
                } catch {
                    throw Abort(.internalServerError, reason: "Failed to get remaining recovery code count")
                }
            }

        case .configuration:
            do {
                let config = try await mfa.configuration()
                return Response.success(true, data: config)
            } catch {
                throw Abort(.internalServerError, reason: "Failed to get MFA configuration")
            }

        case .disable:
            do {
                try await mfa.disable()
                return Response.success(true)
            } catch {
                throw Abort(.internalServerError, reason: "Failed to disable MFA")
            }
        }

    }
}
