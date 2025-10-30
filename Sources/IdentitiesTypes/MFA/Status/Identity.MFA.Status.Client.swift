//
//  Identity.Client.MFA.Status.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies
import DependenciesMacros
import Foundation

extension Identity.MFA.Status {
  /// General MFA status operations.
  @DependencyClient
  public struct Client: @unchecked Sendable {
    /// Get the current MFA status including configured methods and requirements.
    @DependencyEndpoint
    public var get: () async throws -> Identity.MFA.Status.Response

    /// Get MFA challenge after authentication.
    @DependencyEndpoint
    public var challenge: () async throws -> Identity.MFA.Challenge
  }
}

extension Identity.MFA.Status.Client {
  public func callAsFunction() async throws -> Identity.MFA.Status.Response {
    try await self.get()
  }
}
