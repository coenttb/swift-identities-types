//
//  File.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import TypesFoundation

extension Identity.Password {
  /// Namespace containing password change functionality for authenticated users.
  public struct Change: @unchecked Sendable {
    public var client: Identity.Password.Change.Client
    public var router: any URLRouting.Router<Identity.Password.Change.API>

    public init(
      client: Identity.Password.Change.Client,
      router: any URLRouting.Router<Identity.Password.Change.API> = Identity.Password.Change.API
        .Router()
    ) {
      self.client = client
      self.router = router
    }
  }
}

extension Identity.Password.Change {
  /// Type alias for reauthorization requirements during password changes.
  ///
  /// While this type alias creates an indirect namespace path
  /// (`Identity.Password.Change.Reauthorization`), this approach offers several benefits:
  ///
  /// - **Domain Context**: The alias clearly indicates this reauthorization is specifically
  ///   for password changes, making the code's intent more explicit
  ///
  /// - **Feature Isolation**: Allows password-change-specific reauthorization behavior or
  ///   extensions to be added without affecting the base `Identity.Reauthorization` type
  ///
  /// - **Discoverability**: Developers working with password changes will naturally find
  ///   reauthorization requirements through code completion within the `Password.Change` namespace
  ///
  /// - **Type Safety**: Provides semantic meaning - even though it's the same underlying type,
  ///   the alias signals this is specifically for password change flows
  ///
  /// - **Future Flexibility**: If password change reauthorization needs to diverge from the
  ///   base implementation, the alias can be replaced with a distinct type without changing
  ///   the public API
  public typealias Reauthorization = Identity.Reauthorization
}
