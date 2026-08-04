//
//  Identity.Reauthorization+Dependency.Key.Test.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Dependencies
import JWT

extension Identity.Reauthorization: Dependency.Key.Test {
    public static var testValue: Self {
        return Self(
            client: .init(
                reauthorize: { password throws(Identity.Reauthorization.Client.Error) in
                    do {
                        // Create a test JWT token for reauthorization
                        return try .parse(from: "test-reauth-token-\(password)")
                    } catch {
                        throw Identity.Reauthorization.Client.Error.reauthorize(reason: "\(error)")
                    }
                }
            ),
            router: Identity.Reauthorization.Route.Router().eraseToAnyParserPrinter()
        )
    }
}
