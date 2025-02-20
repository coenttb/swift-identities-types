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

extension Identity.Provider.API.Delete {
    package static func response(
        delete: Identity.Provider.API.Delete
    ) async throws -> Response {

        @Dependency(\.identity.provider.client) var client

        switch delete {
        case .request(let request):
            if request.reauthToken.isEmpty {
                throw Abort(.unauthorized, reason: "Invalid token")
            }

            do {
                try await client.delete.request(request)
                return Response.success(true)
            } catch {
                throw Abort(.internalServerError, reason: "Failed to delete")
            }
        case .cancel:
            do {
                try await client.delete.cancel()
                return Response.success(true)
            } catch {
                throw Abort(.internalServerError, reason: "Failed to delete")
            }
        case .confirm:
            do {
                try await client.delete.confirm()
                return Response.success(true)
            } catch {
                throw Abort(.internalServerError, reason: "Failed to confirm deletion")
            }
        }
    }
}
