//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2024.
//

import Foundation
import Coenttb_Vapor
import Coenttb_Web
import Identity_Provider

extension Identity.Provider.API.Password {
    public static func response(
        password: Identity.Provider.API.Password,
        logoutRedirectURL: () -> URL
    ) async throws -> any AsyncResponseEncodable {
        
        @Dependency(Identity.Provider.Client.self) var client
        
        do {
            if let response = try Identity.API.protect(api: .password(password), with: Database.Identity.self) {
                return response
            }
        } catch {
            throw Abort(.unauthorized)
        }
        
        switch password {
        case .reset(let reset):
            switch reset {
            case let .request(request):
                do {
                    try await client.password.reset.request(email: .init(request.email))
                    return Response.success(true)
                } catch {
                    @Dependencies.Dependency(\.logger) var logger
                    logger.log(.error, "Failed to request password reset. Error: \(String(describing: error))")
                    throw Abort(.internalServerError, reason: "Failed to request password reset")
                }
            case let .confirm(confirm):
                do {
                    try await client.password.reset.confirm(
                        newPassword: confirm.newPassword,
                        token: confirm.token
                    )
                    
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
                    try await client.password.change.request(
                        currentPassword: request.currentPassword,
                        newPassword: request.newPassword
                    )
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
