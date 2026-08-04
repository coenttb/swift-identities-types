//
//  Identity.Password+Dependency.Key.Test.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Dependencies
import EmailAddress

extension Identity.Password: Dependency.Key.Test {
    public static var testValue: Self {
        return Self(
            change: .testValue,
            reset: .testValue
        )
    }
}

extension Identity.Password.Reset: Dependency.Key.Test {
    public static var testValue: Self {
        @Dependency(Identity._TestDatabase.self) var database

        return Self(
            client: .init(
                request: { email in
                    do {
                        _ = try EmailAddress(email)
                        _ = try await database.initiatePasswordReset(email: email)
                    } catch {
                        throw Identity.Password.Reset.Client.Error.request(reason: "\(error)")
                    }
                },
                confirm: { newPassword, token in
                    do {
                        try await database.confirmPasswordReset(token: token, newPassword: newPassword)
                    } catch {
                        throw Identity.Password.Reset.Client.Error.confirm(reason: "\(error)")
                    }
                }
            ),
            router: Identity.Password.Reset.API.Router().eraseToAnyParserPrinter()
        )
    }
}

extension Identity.Password.Change: Dependency.Key.Test {
    public static var testValue: Self {
        @Dependency(Identity._TestDatabase.self) var database

        return Self(
            client: .init(
                request: { currentPassword, newPassword in
                    do {
                        guard let email = await database.currentUser else {
                            throw Identity._TestDatabase.TestError.userNotFound
                        }

                        try await database.changePassword(
                            email: email,
                            currentPassword: currentPassword,
                            newPassword: newPassword
                        )
                    } catch {
                        throw Identity.Password.Change.Client.Error.request(reason: "\(error)")
                    }
                }
            ),
            router: Identity.Password.Change.API.Router().eraseToAnyParserPrinter()
        )
    }
}
