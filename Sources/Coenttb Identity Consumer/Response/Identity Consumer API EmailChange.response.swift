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

extension Identity.Consumer.API.EmailChange {
    package static func response(
        emailChange: Identity.Consumer.API.EmailChange
    ) async throws -> any AsyncResponseEncodable {
        
        @Dependency(Identity.Consumer.Client.self) var client
        @Dependency(\.request) var request
        guard let request else { throw Abort.requestUnavailable }
        
        switch emailChange {
        case .request(let request):
            do {
                let data = try await client.emailChange.request(newEmail: try .init(request.newEmail))
                switch data {
                case .success:
                    return Response.success(true)
                case .requiresReauthentication:
                    return Response.success(false, message: "Requires reauthorization")
                }
            }
            catch {
                throw Abort(.internalServerError, reason: "Failed to request email change")
            }
            
        case .confirm(let confirm):
            do {
                try await client.emailChange.confirm(token: confirm.token)
                return Response.success(true)
            } catch {
                throw Abort(.internalServerError, reason: "Failed to confirm email change")
            }
        }
    }
}
