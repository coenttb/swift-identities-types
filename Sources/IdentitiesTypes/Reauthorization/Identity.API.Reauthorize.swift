//
//  Identity.API.Reauthorize.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

extension Identity.API {
    /// Defines the reauthorization API type.
    ///
    /// For consistency with the architecture, this is a typealias to the core
    /// `Identity.Reauthorization` type. This follows the pattern where:
    /// - API enum cases use verbs (`reauthorize`)
    /// - Associated values use nouns (`Reauthorize`)
    /// - The actual type is defined at the root namespace (`Identity.Reauthorization`)
    ///
    /// Example:
    /// ```swift
    /// // In API routing
    /// case .reauthorize(let reauth):
    ///     // reauth is of type Identity.API.Reauthorize (aka Identity.Reauthorization)
    ///
    /// // Usage
    /// let request = Identity.Reauthorization(password: "current_password")
    /// ```
    public typealias Reauthorize = Identity.Reauthorization
}
