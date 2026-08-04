//
//  Identity.OAuth.Provider.Error.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 10/09/2025.
//

extension Identity.OAuth.Provider {
    /// Leaf error for `Identity.OAuth.Provider` conformances. Concrete and typed per the L3
    /// client-modularization leaf-error doctrine — every OAuth provider implementation
    /// (GitHub, Google, …) throws this shared, per-operation-labeled error rather than an
    /// existential `any Swift.Error`.
    public enum Error: Swift.Error, Sendable, Equatable {
        case authorizationURL(reason: String)
        case exchangeCode(reason: String)
        case getUserInfo(reason: String)
        case refreshToken(reason: String)
    }
}
