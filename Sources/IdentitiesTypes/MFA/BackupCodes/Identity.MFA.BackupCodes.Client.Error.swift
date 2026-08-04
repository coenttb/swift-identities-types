//
//  Identity.MFA.BackupCodes.Client.Error.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies

extension Identity.MFA.BackupCodes.Client {
    /// Leaf error for `Identity.MFA.BackupCodes.Client` operations. Concrete, per-client, and
    /// typed per the L3 client-modularization leaf-error doctrine.
    public enum Error: Swift.Error, Sendable, Equatable {
        case regenerate(reason: String)
        case verify(reason: String)
        case remaining(reason: String)

        /// A witness operation was invoked on an `.unimplemented()` placeholder.
        /// (Named `unimplementedWitness`, not `unimplemented`, to avoid colliding with the
        /// `Representable.unimplemented(_:)` static func of the same name.)
        case unimplementedWitness(Witness.Unimplemented.Error)
    }
}

extension Identity.MFA.BackupCodes.Client.Error: Witness.Unimplemented.Representable {
    public static func unimplemented(_ error: Witness.Unimplemented.Error) -> Self {
        .unimplementedWitness(error)
    }
}
