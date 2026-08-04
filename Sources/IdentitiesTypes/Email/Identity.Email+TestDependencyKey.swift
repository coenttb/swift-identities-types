//
//  Identity.Email+Dependency.Key.Test.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Dependencies
import EmailAddress

extension Identity.Email: Dependency.Key.Test {
    public static var testValue: Self {
        return Self(
            change: .testValue
        )
    }
}

extension Identity.Email.Change: Dependency.Key.Test {
    public static var testValue: Self {
        @Dependency(Identity._TestDatabase.self) var database

        return Self(
            client: .init(
                request: { newEmail in
                    do {
                        _ = try EmailAddress(newEmail)
                        guard let currentEmail = await database.currentUser else {
                            throw Identity._TestDatabase.TestError.userNotFound
                        }
                        _ = try await database.initiateEmailChange(
                            currentEmail: currentEmail,
                            newEmail: newEmail
                        )
                        return .success
                    } catch {
                        throw Identity.Email.Change.Client.Error.request(reason: "\(error)")
                    }
                },
                confirm: { token in
                    do {
                        guard let email = await database.currentUser else {
                            throw Identity._TestDatabase.TestError.userNotFound
                        }
                        let session = try await database.confirmEmailChange(email: email, token: token)

                        return .init(
                            accessToken: session.accessToken,
                            refreshToken: session.refreshToken
                        )
                    } catch {
                        throw Identity.Email.Change.Client.Error.confirm(reason: "\(error)")
                    }
                }
            ),
            router: Identity.Email.Change.API.Router().eraseToAnyParserPrinter()
        )
    }
}
