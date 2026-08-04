//
//  Identity.Client.MFA.Status.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies
import Foundation

extension Identity.MFA.Status {
    /// General MFA status operations.
    @Witness
    public struct Client: @unchecked Sendable {
        /// Get the current MFA status including configured methods and requirements.
        public var get: () async throws(any Swift.Error) -> Identity.MFA.Status.Response

        /// Get MFA challenge after authentication.
        public var challenge: () async throws(any Swift.Error) -> Identity.MFA.Challenge
    }
}

extension Identity.MFA.Status.Client {
    public func callAsFunction() async throws -> Identity.MFA.Status.Response {
        try await self.get()
    }
}
