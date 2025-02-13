//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 16/10/2024.
//

import Coenttb_Vapor
import Coenttb_Web
import Favicon
import Identity_Consumer

extension Identity.Consumer.API.Authenticate {
    package static func response(
        authenticate: Identity.Consumer.API.Authenticate,
        tokenDomain: String?
    ) async throws -> any AsyncResponseEncodable {

        @Dependency(Identity.Consumer.Client.self) var client

        do {
            switch authenticate {
            case .token(let token):
                switch token {
                case .access(let access):
                    try await client.authenticate.token.access(token: access.token)
                    return Response.success(true)

                case .refresh(let refresh):
                    let data = try await client.authenticate.token.refresh(token: refresh.token)

                    let response = Response.success(true)
                    response.cookies.refreshToken = .refreshToken(response: data, domain: nil)
                    response.cookies.refreshToken?.sameSite = .strict
                    response.cookies.refreshToken?.isHTTPOnly = true

                    return response
                }

            case .credentials(let credentials):
                do {
                    let data = try await client.authenticate.credentials(credentials)
                    let response = Response.success(true)
                    response.cookies.accessToken = .accessToken(response: data, domain: tokenDomain)
                    response.cookies.refreshToken = .refreshToken(response: data, domain: tokenDomain)
                    return response
                } catch {
                    print("Failed in credentials case with error:", error)
                    throw Abort(.internalServerError, reason: "Failed to authenticate account: \(error)")
                }

            case .apiKey(let apiKey):
                let data = try await client.authenticate.apiKey(apiKey: apiKey.token)
                return Response.success(true, data: data)

            case .multifactor:
                fatalError()
            }

        } catch {
            throw Abort(.internalServerError, reason: "Failed to authenticate account")
        }

    }
}
