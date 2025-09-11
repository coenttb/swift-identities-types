//
//  Identity.Creation+TestDependencyKey.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Dependencies
import EmailAddress

extension Identity.Creation: TestDependencyKey {
    public static var testValue: Self {
        @Dependency(Identity._TestDatabase.self) var database
        
        return Self(
            client: .init(
                request: { email, password in
                    _ = try EmailAddress(email)
                    try await database.createUser(email: email, password: password)
                },
                verify: { email, token in
                    _ = try EmailAddress(email)
                    try await database.verifyUser(email: email, token: token)
                }
            ),
            router: Identity.Creation.Route.Router()
        )
    }
}