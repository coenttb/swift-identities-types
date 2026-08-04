//
//  Identity.MFA.Email.Client.Error.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies

extension Identity.MFA.Email.Client {
    /// Leaf error for `Identity.MFA.Email.Client` operations. Concrete, per-client, and typed
    /// per the L3 client-modularization leaf-error doctrine.
    public enum Error: Swift.Error, Sendable, Equatable {
        case setup(reason: String)
        case requestCode(reason: String)
        case verify(reason: String)
        case updateEmail(reason: String)
        case disable(reason: String)

        /// A witness operation was invoked on an `.unimplemented()` placeholder.
        case unimplemented(Witness.Unimplemented.Error)
    }
}

extension Identity.MFA.Email.Client.Error: Witness.Unimplemented.Representable {
    public static func unimplemented(_ error: Witness.Unimplemented.Error) -> Self {
        .unimplemented(error)
    }
}
