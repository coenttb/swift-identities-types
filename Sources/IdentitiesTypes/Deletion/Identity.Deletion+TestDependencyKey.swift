//
//  Identity.Deletion+TestDependencyKey.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Dependencies

extension Identity.Deletion: TestDependencyKey {
    public static var testValue: Self {
        @Dependency(Identity._TestDatabase.self) var database
        
        return Self(
            client: .init(
                request: { reauthToken in
                    guard let email = await database.currentUser else {
                        throw Identity._TestDatabase.TestError.userNotFound
                    }
                    try await database.requestDeletion(email: email, reauthToken: reauthToken)
                },
                cancel: {
                    guard let email = await database.currentUser else {
                        throw Identity._TestDatabase.TestError.userNotFound
                    }
                    try await database.cancelDeletion(email: email)
                },
                confirm: {
                    guard let email = await database.currentUser else {
                        throw Identity._TestDatabase.TestError.userNotFound
                    }
                    try await database.confirmDeletion(email: email)
                }
            ),
            router: Identity.Deletion.Route.Router()
        )
    }
}