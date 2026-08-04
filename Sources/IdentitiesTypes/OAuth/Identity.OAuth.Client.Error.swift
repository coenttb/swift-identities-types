//
//  Identity.OAuth.Client.Error.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 23/07/2026.
//

import Dependencies

extension Identity.OAuth.Client {
    /// Failure conditions for OAuth client operations.
    public enum Error: Swift.Error, Equatable, Sendable {
        /// A provider with the same identifier is already registered.
        case duplicate(identifier: String)

        /// The implementation refused to register the provider.
        case rejected(identifier: String, reason: String)

        case provider(reason: String)
        case providers(reason: String)
        case authorizationURL(reason: String)
        case callback(reason: String)
        case connection(reason: String)
        case disconnect(reason: String)
        case getValidToken(reason: String)
        case getAllConnections(reason: String)

        /// A witness operation was invoked on an `.unimplemented()` placeholder.
        case unimplemented(Witness.Unimplemented.Error)
    }
}

extension Identity.OAuth.Client.Error: Witness.Unimplemented.Representable {
    public static func unimplemented(_ error: Witness.Unimplemented.Error) -> Self {
        .unimplemented(error)
    }
}
