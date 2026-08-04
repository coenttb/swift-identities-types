//
//  Identity.Deletion+Dependency.Key.Test.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Dependencies

extension Identity.Deletion: Dependency.Key.Test {
    public static var testValue: Self {
        @Dependency(Identity._TestDatabase.self) var database

        return Self(
            client: .init(
                request: { reauthToken throws(Identity.Deletion.Client.Error) in
                    do {
                        guard let email = await database.currentUser else {
                            throw Identity._TestDatabase.TestError.userNotFound
                        }
                        try await database.requestDeletion(email: email, reauthToken: reauthToken)
                    } catch {
                        throw Identity.Deletion.Client.Error.request(reason: "\(error)")
                    }
                },
                cancel: { () throws(Identity.Deletion.Client.Error) in
                    do {
                        guard let email = await database.currentUser else {
                            throw Identity._TestDatabase.TestError.userNotFound
                        }
                        try await database.cancelDeletion(email: email)
                    } catch {
                        throw Identity.Deletion.Client.Error.cancel(reason: "\(error)")
                    }
                },
                confirm: { () throws(Identity.Deletion.Client.Error) in
                    do {
                        guard let email = await database.currentUser else {
                            throw Identity._TestDatabase.TestError.userNotFound
                        }
                        try await database.confirmDeletion(email: email)
                    } catch {
                        throw Identity.Deletion.Client.Error.confirm(reason: "\(error)")
                    }
                }
            ),
            router: Identity.Deletion.Route.Router().eraseToAnyParserPrinter()
        )
    }
}
