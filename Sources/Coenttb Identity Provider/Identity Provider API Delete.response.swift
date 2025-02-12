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

extension Identity.Provider.API.Delete {
    public static func response(
        delete: Identity.Provider.API.Delete,
        logoutRedirectURL: () -> URL
    ) async throws -> any AsyncResponseEncodable {
        
        @Dependency(Identity.Provider.Client.self) var client
        
        do {
            if let response = try Identity.API.protect(api: .delete(delete), with: Database.Identity.self) {
                return response
            }
        } catch {
            throw Abort(.unauthorized)
        }
        
        switch delete {
        case .request(let request):
            if request.reauthToken.isEmpty {
                throw Abort(.unauthorized, reason: "Invalid token")
            }
            
            do {
                try await client.delete.request(reauthToken: request.reauthToken)
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
