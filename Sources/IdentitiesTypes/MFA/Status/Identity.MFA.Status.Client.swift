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
        // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
        /// Get the current MFA status including configured methods and requirements.
        public var get: () async throws(any Swift.Error) -> Identity.MFA.Status.Response
        // swiftlint:enable no_any_protocol_existential

        // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
        /// Get MFA challenge after authentication.
        public var challenge: () async throws(any Swift.Error) -> Identity.MFA.Challenge
        // swiftlint:enable no_any_protocol_existential
    }
}

extension Identity.MFA.Status.Client {
    // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
    public func callAsFunction() async throws(any Swift.Error) -> Identity.MFA.Status.Response {
        // swiftlint:enable no_any_protocol_existential
        try await self.get()
    }
}
