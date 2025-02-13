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

extension Identity.Consumer.API.Delete {
    package static func response(
        delete: Identity.Consumer.API.Delete
    ) async throws -> any AsyncResponseEncodable {

        @Dependency(Identity.Consumer.Client.self) var client

        switch delete {
        case .request(let request):
            do {
                try await client.delete.request(request)
                return Response.success(true)
            } catch {
                throw Abort(.internalServerError, reason: "Failed to delete account")
            }

        case .cancel:
            do {
                try await client.delete.cancel()
                return Response.success(true)
            } catch {
                throw Abort(.internalServerError, reason: "Failed to cancel account deletion")
            }

        case .confirm:
            do {
                try await client.delete.confirm()
                return Response.success(true)
            } catch {
                throw Abort(.internalServerError, reason: "Failed to confirm account deletion")
            }
        }
    }
}
