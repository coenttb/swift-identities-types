//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 11/02/2025.
//

import Coenttb_Identity_Shared
import Coenttb_Vapor
import Coenttb_Web
import Dependencies
import EmailAddress
import Identities
import Identities
import JWT
import RateLimiter

extension Identity.Consumer.Client.Email {
    package static func live(
        
    ) -> Self {
        @Dependency(\.identity.consumer.client) var client
        
        return Identity.Consumer.Client.Email(
            change: .init(
                request: { newEmail in

                    do {
                        return try await client.handleRequest(
                            for: .email(.change(.request(.init(newEmail: newEmail)))),
                            decodingTo: Identity.Email.Change.Request.Result.self
                        )
                    } catch {
                        throw Abort(.unauthorized)
                    }
                },
                confirm: { token in
                    do {
                        return try await client.handleRequest(
                            for: .email(.change(.confirm(.init(token: token)))),
                            decodingTo: Identity.Email.Change.Confirmation.Response.self
                        )
                        
                    } catch {
                        throw Abort(.internalServerError)
                    }
                }
            )
        )
    }
}
