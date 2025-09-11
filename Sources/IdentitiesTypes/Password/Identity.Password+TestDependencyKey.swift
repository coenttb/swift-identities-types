//
//  Identity.Password+TestDependencyKey.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Dependencies
import EmailAddress

extension Identity.Password: TestDependencyKey {
    public static var testValue: Self {
        return Self(
            change: .testValue,
            reset: .testValue
        )
    }
}

extension Identity.Password.Reset: TestDependencyKey {
    public static var testValue: Self {
        @Dependency(Identity._TestDatabase.self) var database
        
        return Self(
            client: .init(
                request: { email in
                    _ = try EmailAddress(email)
                    _ = try await database.initiatePasswordReset(email: email)
                },
                confirm: { newPassword, token in
                    try await database.confirmPasswordReset(token: token, newPassword: newPassword)
                }
            ),
            router: Identity.Password.Reset.API.Router()
        )
    }
}

extension Identity.Password.Change: TestDependencyKey {
    public static var testValue: Self {
        @Dependency(Identity._TestDatabase.self) var database
        
        return Self(
            client: .init(
                request: { currentPassword, newPassword in
                    guard let email = await database.currentUser else {
                        throw Identity._TestDatabase.TestError.userNotFound
                    }
                    
                    try await database.changePassword(email: email, currentPassword: currentPassword, newPassword: newPassword)
                }
            ),
            router: Identity.Password.Change.API.Router()
        )
    }
}