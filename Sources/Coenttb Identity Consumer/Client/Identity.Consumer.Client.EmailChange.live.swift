//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 11/02/2025.
//

import Coenttb_Identity_Shared
import Coenttb_Vapor
import Coenttb_Web
import Dependencies
import EmailAddress
import Identity_Consumer
import Identity_Shared
import JWT
import RateLimiter

extension Identity.Consumer.Client.EmailChange {
    package static func live(
        
    ) -> Self {
        @Dependency(Identity.Consumer.Client.self) var client
        
        return .init(
            request: { newEmail in

                do {
                    return try await client.handleRequest(
                        for: .emailChange(.request(.init(newEmail: newEmail))),
                        decodingTo: Identity.EmailChange.Request.Result.self
                    )
                } catch {
                    throw Abort(.unauthorized)
                }
            },
            confirm: { token in
                do {
                    return try await client.handleRequest(
                        for: .emailChange(.confirm(.init(token: token))),
                        decodingTo: Identity.EmailChange.Confirm.Response.self
                    )
                    
                } catch {
                    throw Abort(.internalServerError)
                }
            }
        )
    }
}
