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

extension Identity.Provider.API.Create {
    public static func response(
        create: Identity.Provider.API.Create,
        logoutRedirectURL: () -> URL
    ) async throws -> any AsyncResponseEncodable {
        
        @Dependency(Identity.Provider.Client.self) var client

        switch create {
        case .request(let request):
            do {
                try await client.create.request(email: .init(request.email), password: request.password)
                return Response.success(true)
            } catch {
                @Dependencies.Dependency(\.logger) var logger
                logger.log(.critical, "Failed to create account. Error: \(String(describing: error))")
                
                throw Abort(.internalServerError, reason: "Failed to request account creation")
            }
        case .verify(let verify):
            do {
                try await client.create.verify(email: .init(verify.email), token: verify.token)
                return Response.success(true)
            } catch {
                print(error)
                throw Abort(.internalServerError, reason: "Failed to verify account creation")
            }
        }
    }
}
