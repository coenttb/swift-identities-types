//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 16/10/2024.
//

import Coenttb_Vapor
import Coenttb_Web
import Favicon
import Identities

extension Identity.Consumer.API {
    public static func response(
        api: Identity.Consumer.API
    ) async throws -> Response {

        @Dependency(\.identity.consumer.client) var client

        do {
            try Identity.Consumer.API.protect(
                api: api,
                with: JWT.Token.Access.self
            )
        } catch {
            throw Abort(.unauthorized)
        }

        @Dependency(\.identity.consumer.rateLimiters) var rateLimiter

        let rateLimitClient = try await Identity.API.rateLimit(
            api: api,
            rateLimiter: rateLimiter
        )

        do {
            switch api {
            case .authenticate(let authenticate):
                let response = try await Identity.Consumer.API.Authenticate.response(authenticate: authenticate)
                await rateLimitClient.recordSuccess()
                return response

            case .create(let create):
                let response = try await Identity.Consumer.API.Create.response(create: create)
                await rateLimitClient.recordSuccess()
                return response

            case .delete(let delete):
                let response = try await Identity.Consumer.API.Delete.response(delete: delete)
                await rateLimitClient.recordSuccess()
                return response

            case .email(let email):
                let response = try await Identity.Consumer.API.Email.Change.response(email: email)
                await rateLimitClient.recordSuccess()
                return response

            case .logout:
                try await client.logout()

                let response = Response.success(true)

                response.expire(cookies: .identity)

                await rateLimitClient.recordSuccess()

                return response

            case .password(let password):
                let response = try await Identity.Consumer.API.Password.response(password: password)

                await rateLimitClient.recordSuccess()

                return response

            case .reauthorize(let reauthorize):
                let data = try await client.reauthorize(password: reauthorize.password)

                let response = Response.success(true)
                response.cookies.reauthorizationToken = .init(string: data.value)

                await rateLimitClient.recordSuccess()

                return response
            }
        } catch {
            await rateLimitClient.recordFailure()
            throw error
        }
    }
}
