//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 16/10/2024.
//

import Coenttb_Web
import Coenttb_Vapor
import Favicon
import Identity_Consumer

extension Identity.Consumer.API.Password {
    package static func response(
        password: Identity.Consumer.API.Password
    ) async throws -> any AsyncResponseEncodable {
        
        @Dependency(Identity.Consumer.Client.self) var client
        @Dependency(\.request) var request
        guard let request else { throw Abort.requestUnavailable }
        
        switch password {
        case .reset(let reset):
            switch reset {
            case .request(let request):
                do {
                    try await client.password.reset.request(email: try .init(request.email))
                    return Response.success(true)
                } catch {
                    throw Abort(.internalServerError, reason: "Failed to request password reset")
                }
                
            case .confirm(let confirm):
                do {
                    try await client.password.reset.confirm(newPassword: confirm.newPassword, token: confirm.token)
                    return Response.success(true)
                } catch {
                    throw Abort(.internalServerError, reason: "Failed to confirm password reset")
                }
            }
        case .change(let change):
            switch change {
            case .request(let request):
                do {
                    try await client.password.change.request(
                        currentPassword: request.currentPassword,
                        newPassword: request.newPassword
                    )
                    return Response.success(true)
                } catch {
                    throw Abort(.internalServerError, reason: "Failed to request password change")
                }
            }
        }
    }
}
