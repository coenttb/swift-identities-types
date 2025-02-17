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

extension Identity.Consumer.Client.Password {
    package static func live(
        
    ) -> Self {
        
        @Dependency(\.identity.consumer.client) var client
        
        return .init(
            reset: .init(
                request: { email in
                    do {
                        try await client.handleRequest(for: .password(.reset(.request(.init(email: email)))))
                    } catch {
                        throw Abort(.unauthorized)
                    }
                },
                confirm: { token, newPassword in
                    do {
                        try await client.handleRequest(for: .password(.reset(.confirm(.init(token: token, newPassword: newPassword)))))
                    } catch {
                        throw Abort(.internalServerError)
                    }
                }
            ),
            change: .init(
                request: { currentPassword, newPassword in
                    do {
                        try await client.handleRequest(for: .password(.change(.request(change: .init(currentPassword: currentPassword, newPassword: newPassword)))))
                    } catch {
                        throw Abort(.unauthorized)
                    }
                }
            )
        )
    }
}
