//
//  Identity.Creation.Client.Error.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 12/02/2025.
//

import Dependencies

extension Identity.Creation.Client {
    /// Leaf error for `Identity.Creation.Client` operations. Concrete, per-client, and typed
    /// per the L3 client-modularization leaf-error doctrine.
    public enum Error: Swift.Error, Sendable, Equatable {
        case request(reason: String)
        case verify(reason: String)

        /// A witness operation was invoked on an `.unimplemented()` placeholder.
        case unimplemented(Witness.Unimplemented.Error)
    }
}

extension Identity.Creation.Client.Error: Witness.Unimplemented.Representable {
    public static func unimplemented(_ error: Witness.Unimplemented.Error) -> Self {
        .unimplemented(error)
    }
}
