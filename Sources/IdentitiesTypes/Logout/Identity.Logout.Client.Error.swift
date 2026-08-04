//
//  Identity.Logout.Client.Error.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies

extension Identity.Logout.Client {
    /// Leaf error for `Identity.Logout.Client` operations. Concrete, per-client, and typed
    /// per the L3 client-modularization leaf-error doctrine.
    public enum Error: Swift.Error, Sendable, Equatable {
        case current(reason: String)
        case all(reason: String)

        /// A witness operation was invoked on an `.unimplemented()` placeholder.
        /// (Named `unimplementedWitness`, not `unimplemented`, to avoid colliding with the
        /// `Representable.unimplemented(_:)` static func of the same name.)
        case unimplementedWitness(Witness.Unimplemented.Error)
    }
}

extension Identity.Logout.Client.Error: Witness.Unimplemented.Representable {
    public static func unimplemented(_ error: Witness.Unimplemented.Error) -> Self {
        .unimplementedWitness(error)
    }
}
