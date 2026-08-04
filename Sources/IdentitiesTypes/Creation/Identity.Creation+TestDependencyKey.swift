//
//  Identity.Creation+Dependency.Key.Test.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Dependencies
import EmailAddress

extension Identity.Creation: Dependency.Key.Test {
    public static var testValue: Self {
        @Dependency(Identity._TestDatabase.self) var database

        return Self(
            client: .init(
                request: { email, password throws(Identity.Creation.Client.Error) in
                    do {
                        _ = try EmailAddress(email)
                        try await database.createUser(email: email, password: password)
                    } catch {
                        throw Identity.Creation.Client.Error.request(reason: "\(error)")
                    }
                },
                verify: { email, token throws(Identity.Creation.Client.Error) in
                    do {
                        _ = try EmailAddress(email)
                        try await database.verifyUser(email: email, token: token)
                    } catch {
                        throw Identity.Creation.Client.Error.verify(reason: "\(error)")
                    }
                }
            ),
            router: Identity.Creation.Route.Router().eraseToAnyParserPrinter()
        )
    }
}
