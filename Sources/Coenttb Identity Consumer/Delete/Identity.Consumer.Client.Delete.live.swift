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
import JWT
import RateLimiter

extension Identity.Consumer.Client.Delete {
    package static func live(

    ) -> Self {
        @Dependency(\.identity.consumer.client) var client
        return .init(
            request: { reauthToken in
                do {
                    try await client.handleRequest(for: .delete(.request(.init(reauthToken: reauthToken))))
                } catch {
                    throw Abort(.unauthorized)
                }
            },
            cancel: {
                do {
                    try await client.handleRequest(for: .delete(.cancel))
                } catch {
                    throw Abort(.unauthorized)
                }
            },
            confirm: {
                do {
                    try await client.handleRequest(for: .delete(.confirm))
                } catch {
                    throw Abort(.unauthorized)
                }
            }
        )
    }
}
