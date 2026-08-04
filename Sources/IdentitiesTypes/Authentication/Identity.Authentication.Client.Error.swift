//
//  Identity.Authentication.Client.Error.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 12/02/2025.
//

import Dependencies

extension Identity.Authentication.Client {
    /// Leaf error for `Identity.Authentication.Client` operations. Concrete, per-client, and
    /// typed per the L3 client-modularization leaf-error doctrine.
    public enum Error: Swift.Error, Sendable, Equatable {
        case credentials(reason: String)
        case apiKey(reason: String)

        /// A witness operation was invoked on an `.unimplemented()` placeholder.
        /// (Named `unimplementedWitness`, not `unimplemented`, to avoid colliding with the
        /// `Representable.unimplemented(_:)` static func of the same name.)
        case unimplementedWitness(Witness.Unimplemented.Error)
    }
}

extension Identity.Authentication.Client.Error: Witness.Unimplemented.Representable {
    public static func unimplemented(_ error: Witness.Unimplemented.Error) -> Self {
        .unimplementedWitness(error)
    }
}

extension Identity.Authentication.Token.Client {
    /// Leaf error for `Identity.Authentication.Token.Client` operations. Concrete, per-client,
    /// and typed per the L3 client-modularization leaf-error doctrine.
    public enum Error: Swift.Error, Sendable, Equatable {
        case access(reason: String)
        case refresh(reason: String)

        /// A witness operation was invoked on an `.unimplemented()` placeholder.
        /// (Named `unimplementedWitness`, not `unimplemented`, to avoid colliding with the
        /// `Representable.unimplemented(_:)` static func of the same name.)
        case unimplementedWitness(Witness.Unimplemented.Error)
    }
}

extension Identity.Authentication.Token.Client.Error: Witness.Unimplemented.Representable {
    public static func unimplemented(_ error: Witness.Unimplemented.Error) -> Self {
        .unimplementedWitness(error)
    }
}
