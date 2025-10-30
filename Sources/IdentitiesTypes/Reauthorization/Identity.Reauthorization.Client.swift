//
//  File.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import DependenciesMacros
import JWT
import TypesFoundation

extension Identity.Reauthorization {
  @DependencyClient
  public struct Client: @unchecked Sendable {
    public var reauthorize: (_ password: String) async throws -> JWT
  }
}
