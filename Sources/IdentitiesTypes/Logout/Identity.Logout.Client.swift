//
//  Identity.Client.Logout.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import Dependencies
import Foundation

extension Identity.Logout {
    /// Interface for logout operations.
    ///
    /// This struct provides methods for different logout strategies:
    /// - `current`: Logs out only the current session
    /// - `all`: Logs out all sessions across all devices by incrementing sessionVersion
    @Witness
    public struct Client: @unchecked Sendable {
        /// Logs out the current session only
        public var current: () async throws(any Swift.Error) -> Void

        /// Logs out all sessions for the user across all devices
        public var all: () async throws(any Swift.Error) -> Void
    }
}
