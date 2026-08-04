//
//  Identity.Reauthorization.Client.Error.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Dependencies

extension Identity.Reauthorization.Client {
    /// Leaf error for `Identity.Reauthorization.Client` operations. Concrete, per-client, and
    /// typed per the L3 client-modularization leaf-error doctrine.
    public enum Error: Swift.Error, Sendable, Equatable {
        case reauthorize(reason: String)

        /// A witness operation was invoked on an `.unimplemented()` placeholder.
        case unimplemented(Witness.Unimplemented.Error)
    }
}

extension Identity.Reauthorization.Client.Error: Witness.Unimplemented.Representable {
    public static func unimplemented(_ error: Witness.Unimplemented.Error) -> Self {
        .unimplemented(error)
    }
}
