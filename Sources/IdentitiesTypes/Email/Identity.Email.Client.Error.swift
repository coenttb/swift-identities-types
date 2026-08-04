//
//  Identity.Email.Client.Error.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 18/02/2025.
//

import Dependencies

extension Identity.Email.Change.Client {
    /// Leaf error for `Identity.Email.Change.Client` operations. Concrete, per-client, and
    /// typed per the L3 client-modularization leaf-error doctrine.
    public enum Error: Swift.Error, Sendable, Equatable {
        case request(reason: String)
        case confirm(reason: String)

        /// A witness operation was invoked on an `.unimplemented()` placeholder.
        case unimplemented(Witness.Unimplemented.Error)
    }
}

extension Identity.Email.Change.Client.Error: Witness.Unimplemented.Representable {
    public static func unimplemented(_ error: Witness.Unimplemented.Error) -> Self {
        .unimplemented(error)
    }
}
