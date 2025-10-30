//
//  Identity.Reauthorization.API.swift
//  swift-web
//
//  Created by Coen ten Thije Boonkkamp on 17/10/2024.
//

extension Identity.Reauthorization {
  /// Defines the reauthorization API type.
  ///
  /// For consistency with the architecture, this is a typealias to the core
  /// `Identity.Reauthorization.Request` type.
  ///
  /// Example:
  /// ```swift
  /// // In API routing
  /// case .reauthorize(let reauth):
  ///     // reauth is of type Identity.Reauthorization.API
  ///
  /// // Usage
  /// let request = Identity.Reauthorization.Request(password: "current_password")
  /// ```
  public typealias API = Identity.Reauthorization.Request
}
