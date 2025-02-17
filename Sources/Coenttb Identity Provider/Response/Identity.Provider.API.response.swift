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

extension Identity.Provider.API {
    public static func response(
        api: Identity.Provider.API,
        logoutRedirectURL: () -> URL
    ) async throws -> Response {
        
        let rateLimitClient = try await Identity.API.rateLimit(api: api)

        do {
            try Identity.API.protect(api: api, with: Database.Identity.self)
        } catch {
            throw Abort(.unauthorized)
        }
        
        @Dependency(\.identity.provider.client) var client
        
        switch api {
        case .authenticate(let authenticate):
            do {
                let response = try await Identity.Provider.API.Authenticate.response(authenticate: authenticate, logoutRedirectURL: logoutRedirectURL)
                await rateLimitClient.recordSuccess()
                return response
            } catch {
                await rateLimitClient.recordFailure()
                throw error
            }

        case .create(let create):
            do {
                let response = try await Identity.Provider.API.Create.response(create: create)
                await rateLimitClient.recordSuccess()
                return response
            } catch {
                await rateLimitClient.recordFailure()
                throw error
            }

        case .delete(let delete):
            do {
                let response = try await Identity.Provider.API.Delete.response(delete: delete)
                await rateLimitClient.recordSuccess()
                return response
            } catch {
                await rateLimitClient.recordFailure()
                throw error
            }

        case .logout:
            try await client.logout()
            @Dependency(\.request) var request
            guard let request else { throw Abort.requestUnavailable }

            return request.redirect(to: logoutRedirectURL().absoluteString)

        case let .password(password):
            do {
                let response = try await Identity.Provider.API.Password.response(password: password)
                await rateLimitClient.recordSuccess()
                return response
            } catch {
                await rateLimitClient.recordFailure()
                throw error
            }

        case let .emailChange(emailChange):
            do {
                let response = try await Identity.Provider.API.EmailChange.response(emailChange: emailChange)
                await rateLimitClient.recordSuccess()
                return response
            } catch {
                await rateLimitClient.recordFailure()
                throw error
            }

        case .reauthorize(let reauthorize):
            let data = try await client.reauthorize(password: reauthorize.password)
            return Response.success(true, data: data)
        }
    }
}
