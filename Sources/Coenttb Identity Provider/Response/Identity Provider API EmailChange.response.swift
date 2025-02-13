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

extension Identity.Provider.API.EmailChange {
    package static func response(
        emailChange: Identity.Provider.API.EmailChange
    ) async throws -> any AsyncResponseEncodable {
        
        @Dependency(Identity.Provider.Client.self) var client
        
        do {
            if let response = try Identity.API.protect(api: .emailChange(emailChange), with: Database.Identity.self) {
                return response
            }
        } catch {
            throw Abort(.unauthorized)
        }
        
        switch emailChange {
        case .request(let request):
            do {
                let data = try await client.emailChange.request(newEmail: .init(request.newEmail))
                
                return Response.success(true, data: data)
            }
            catch {
                @Dependencies.Dependency(\.logger) var logger
                logger.log(.error, "Failed to request email change. Error: \(String(describing: error))")
                throw Abort(.internalServerError, reason: "Failed to request email change")
            }
            
        case .confirm(let confirm):
            do {
                try await client.emailChange.confirm(token: confirm.token)
                
                @Dependencies.Dependency(\.logger) var logger
                logger.log(.info, "Email change confirmed for new email")
                
                return Response.success(true)
            } catch {
                @Dependencies.Dependency(\.logger) var logger
                logger.log(.error, "Failed to confirm email change. Error: \(String(describing: error))")
                throw Abort(.internalServerError, reason: "Failed to confirm email change")
            }
        }
    }
}
