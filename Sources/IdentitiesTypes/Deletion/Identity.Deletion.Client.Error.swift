//
//  Identity.Deletion.Client.Error.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 12/02/2025.
//

import Dependencies

extension Identity.Deletion.Client {
    /// Leaf error for `Identity.Deletion.Client` operations. Concrete, per-client, and typed
    /// per the L3 client-modularization leaf-error doctrine.
    public enum Error: Swift.Error, Sendable, Equatable {
        case request(reason: String)
        case cancel(reason: String)
        case confirm(reason: String)

        /// A witness operation was invoked on an `.unimplemented()` placeholder.
        /// (Named `unimplementedWitness`, not `unimplemented`, to avoid colliding with the
        /// `Representable.unimplemented(_:)` static func of the same name.)
        case unimplementedWitness(Witness.Unimplemented.Error)
    }
}

extension Identity.Deletion.Client.Error: Witness.Unimplemented.Representable {
    public static func unimplemented(_ error: Witness.Unimplemented.Error) -> Self {
        .unimplementedWitness(error)
    }
}
