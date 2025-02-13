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

extension Identity.Consumer.API.EmailChange {
    package static func response(
        emailChange: Identity.Consumer.API.EmailChange
    ) async throws -> any AsyncResponseEncodable {

        @Dependency(Identity.Consumer.Client.self) var client

        switch emailChange {
        case .request(let request):
            do {
                let data = try await client.emailChange.request(request)
                switch data {
                case .success:
                    return Response.success(true)
                case .requiresReauthentication:
                    return Response.success(false, message: "Requires reauthorization")
                }
            } catch {
                throw Abort(.internalServerError, reason: "Failed to request email change")
            }

        case .confirm(let confirm):
            do {
                let tokens = try await client.emailChange.confirm(confirm)
                return Response.success(true).with(tokens, domain: nil)
            } catch {
                throw Abort(.internalServerError, reason: "Failed to confirm email change")
            }
        }
    }
}
