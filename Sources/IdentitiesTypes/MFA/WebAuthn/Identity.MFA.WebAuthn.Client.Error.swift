//
//  Identity.MFA.WebAuthn.Client.Error.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies

extension Identity.MFA.WebAuthn.Client {
    /// Leaf error for `Identity.MFA.WebAuthn.Client` operations. Concrete, per-client, and
    /// typed per the L3 client-modularization leaf-error doctrine.
    public enum Error: Swift.Error, Sendable, Equatable {
        case beginRegistration(reason: String)
        case finishRegistration(reason: String)
        case beginAuthentication(reason: String)
        case finishAuthentication(reason: String)
        case listCredentials(reason: String)
        case removeCredential(reason: String)
        case disable(reason: String)

        /// A witness operation was invoked on an `.unimplemented()` placeholder.
        /// (Named `unimplementedWitness`, not `unimplemented`, to avoid colliding with the
        /// `Representable.unimplemented(_:)` static func of the same name.)
        case unimplementedWitness(Witness.Unimplemented.Error)
    }
}

extension Identity.MFA.WebAuthn.Client.Error: Witness.Unimplemented.Representable {
    public static func unimplemented(_ error: Witness.Unimplemented.Error) -> Self {
        .unimplementedWitness(error)
    }
}
