//
//  Identity.Authentication+Dependency.Key.Test.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Dependencies
import Foundation
import JWT

extension Identity.Authentication: Dependency.Key.Test {
    public static var testValue: Self {
        @Dependency(Identity._TestDatabase.self) var database

        return Self(
            client: .init(
                credentials: { username, password throws(Identity.Authentication.Client.Error) in
                    do {
                        let session = try await database.authenticate(
                            email: username,
                            password: password
                        )
                        return .init(
                            accessToken: session.accessToken,
                            refreshToken: session.refreshToken
                        )
                    } catch {
                        throw Identity.Authentication.Client.Error.credentials(reason: "\(error)")
                    }
                },
                apiKey: { apiKey in
                    .init(
                        accessToken: apiKey,
                        refreshToken: apiKey
                    )
                }
            ),
            router: Identity.Authentication.Route.Router().eraseToAnyParserPrinter(),
            token: .init(
                access: { token throws(Identity.Authentication.Token.Client.Error) in
                    do {
                        try await database.validateAccessToken(token)
                    } catch {
                        throw Identity.Authentication.Token.Client.Error.access(reason: "\(error)")
                    }
                },
                refresh: { token throws(Identity.Authentication.Token.Client.Error) in
                    do {
                        let session = try await database.refreshSession(token: token)
                        return .init(
                            accessToken: session.accessToken,
                            refreshToken: session.refreshToken
                        )
                    } catch {
                        throw Identity.Authentication.Token.Client.Error.refresh(reason: "\(error)")
                    }
                }
            )
        )
    }
}
