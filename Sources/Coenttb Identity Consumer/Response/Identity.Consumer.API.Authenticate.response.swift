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
        authenticate: Identity.Consumer.API.Authenticate
    ) async throws -> Response {

        @Dependency(Identity.Consumer.Client.self) var client

        do {
            switch authenticate {
            case .token(let token):
                switch token {
                case .access(let access):
                    @Dependency(\.request) var request
                    guard let request else { throw Abort.requestUnavailable }
                    
                    if let tokens = try await client.login(
                        request: request,
                        accessToken: access.token,
                        refreshToken: \.cookies.refreshToken?.string
                    ) {
                        return Response.success(true).with(tokens, domain: nil)
                    }
                    return Response.success(true)
                    
                case .refresh(let refresh):
                    let tokens = try await client.authenticate.token.refresh(token: refresh.token)
                    return Response.success(true).with(tokens, domain: nil)
                }

            case .credentials(let credentials):
                do {
                    let data = try await client.authenticate.credentials(credentials)
                    let response = Response.success(true)
                    response.cookies.accessToken = .init(token: data.accessToken.value)
                    response.cookies.refreshToken = .init(token: data.refreshToken.value)
                    return response
                } catch {
                    print("Failed in credentials case with error:", error)
                    throw Abort(.internalServerError, reason: "Failed to authenticate account: \(error)")
                }

            case .apiKey(let apiKey):
                let data = try await client.authenticate.apiKey(apiKey: apiKey.token)
                return Response.success(true, data: data)

            }

        } catch {
            throw Abort(.internalServerError, reason: "Failed to authenticate account")
        }
    }
}
