//
//  Identity+Dependency.Key.Test.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Dependencies

extension Identity: Dependency.Key.Test {
    public static var testValue: Self {
        return Self(
            authenticate: .testValue,
            logout: .testValue,
            reauthorize: .testValue,
            require: { () throws(Identity.Error) in throw Identity.Error.notConfigured },
            create: .testValue,
            delete: .testValue,
            email: .testValue,
            password: .testValue,
            mfa: nil,  // MFA not configured in test implementation
            oauth: nil  // OAuth not configured in test implementation
        )
    }
}
