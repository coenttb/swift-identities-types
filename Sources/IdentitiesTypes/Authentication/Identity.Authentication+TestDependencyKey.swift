//
//  Identity.Authentication+TestDependencyKey.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Dependencies
import Foundation
import JWT

extension Identity.Authentication: TestDependencyKey {
    public static var testValue: Self {
        @Dependency(Identity._TestDatabase.self) var database
        
        return Self(
            client: .init(
                credentials: { username, password in
                    let session = try await database.authenticate(email: username, password: password)
                    return .init(
                        accessToken: session.accessToken,
                        refreshToken: session.refreshToken
                    )
                },
                apiKey: { apiKey in
                    .init(
                        accessToken: apiKey,
                        refreshToken: apiKey
                    )
                }
            ),
            router: Identity.Authentication.Route.Router(),
            token: .init(
                access: { token in
                    try await database.validateAccessToken(token)
                },
                refresh: { token in
                    let session = try await database.refreshSession(token: token)
                    return .init(
                        accessToken: session.accessToken,
                        refreshToken: session.refreshToken
                    )
                }
            )
        )
    }
}
