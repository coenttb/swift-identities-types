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

extension Identity.Consumer.API.Create {
    package static func response(
        create: Identity.Consumer.API.Create
    ) async throws -> any AsyncResponseEncodable {
        
        @Dependency(Identity.Consumer.Client.self) var client
        @Dependency(\.request) var request
        guard let request else { throw Abort.requestUnavailable }
        
        switch create {
        case .request(let request):
            do {
                try await client.create.request(email: try .init(request.email), password: request.password)
                return Response.success(true)
            } catch {
                throw Abort(.internalServerError, reason: "Failed to request account creation")
            }
            
        case .verify(let verify):
            do {
                try await client.create.verify(email: try .init(verify.email), token: verify.token)
                return Response.success(true)
            } catch {
                throw Abort(.internalServerError, reason: "Failed to verify account creation")
            }
        }
    }
}
