//
//  Identity+TestDependencyKey.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Dependencies

extension Identity: TestDependencyKey {
    public static var testValue: Self {
        return Self(
            authenticate: .testValue,
            logout: .testValue,
            reauthorize: .testValue,
            create: .testValue,
            delete: .testValue,
            email: .testValue,
            password: .testValue,
            mfa: nil,  // MFA not configured in test implementation
            oauth: nil  // OAuth not configured in test implementation
        )
    }
}
