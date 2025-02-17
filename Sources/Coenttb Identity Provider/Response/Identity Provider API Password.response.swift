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

extension Identity.Provider.API.Password {
    package static func response(
        password: Identity.Provider.API.Password
    ) async throws -> Response {

        @Dependency(Identity.Provider.Client.self) var client

        switch password {
        case .reset(let reset):
            switch reset {
            case let .request(request):
                do {
                    try await client.password.reset.request(request)
                    return Response.success(true)
                } catch {
                    @Dependencies.Dependency(\.logger) var logger
                    logger.log(.error, "Failed to request password reset. Error: \(String(describing: error))")
                    throw Abort(.internalServerError, reason: "Failed to request password reset")
                }
            case let .confirm(confirm):
                do {
                    try await client.password.reset.confirm(confirm)

                    return Response.success(true)
                } catch {
                    @Dependencies.Dependency(\.logger) var logger
                    logger.log(.error, "Failed to reset password. Error: \(String(describing: error))")
                    throw Abort(.internalServerError, reason: "Failed to reset password")
                }
            }
        case .change(let change):
            switch change {
            case let .request(change: request):
                do {
                    try await client.password.change.request(request)
                    return Response.success(true)
                } catch {
                    @Dependencies.Dependency(\.logger) var logger
                    logger.log(.error, "Failed to change password. Error: \(String(describing: error))")
                    throw Abort(.internalServerError, reason: "Failed to change password")
                }
            }
        }
    }
}
