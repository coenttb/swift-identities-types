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
import Identity_Consumer
import Identity_Shared
import JWT
import RateLimiter

extension Identity.Consumer.Client.Create {
    package static func live(
        
    ) -> Self {
        @Dependency(\.identity.consumer.client) var client
        
        return .init(
            request: { email, password in
                do {
                    try await client.handleRequest(for: .create(.request(.init(email: email, password: password))))
                }
                catch {
                    throw Abort(.internalServerError)
                }
            },
            verify: { email, token in
                do {
                    try await client.handleRequest(for: .create(.verify(.init(token: token, email: email))))
                }
                catch {
                    throw Abort(.internalServerError)
                }
            }
        )
    }
}
