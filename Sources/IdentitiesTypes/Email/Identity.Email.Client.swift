//
//  Identity.Client.Email.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 18/02/2025.
//

import Dependencies
import EmailAddress
import Foundation

extension Identity.Email.Change {
    /// Handles the email change process.
    ///
    /// The change process consists of two steps:
    /// 1. Requesting the email change
    /// 2. Confirming the change with a token
    ///
    /// > Important: Email changes require verification to prevent unauthorized changes
    /// and ensure the new email is valid and accessible.
    @Witness
    public struct Client: @unchecked Sendable {
        /// Initiates an email change request.
        ///
        /// This method:
        /// 1. Validates the new email address
        /// 2. Sends a confirmation email
        /// 3. Returns the request result
        ///
        /// - Parameter newEmail: The new email address to change to
        /// - Returns: The result of the change request, indicating success or if re-authentication is required
        public var request:
            // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            (_ newEmail: String) async throws(any Swift.Error) ->
                // swiftlint:enable no_any_protocol_existential
                Identity.Email.Change.Request.Result

        /// Confirms an email change with a verification token.
        ///
        /// This method:
        /// 1. Validates the confirmation token
        /// 2. Updates the email address
        /// 3. Returns the confirmation response
        ///
        /// - Parameter token: The verification token from the confirmation email
        /// - Returns: Response containing updated authentication information
        public var confirm:
            // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
            (_ token: String) async throws(any Swift.Error) ->
                // swiftlint:enable no_any_protocol_existential
                Identity.Email.Change.Confirmation.Response
    }
}

// MARK: - Conveniences
extension Identity.Email.Change.Client {
    /// Convenience method for requesting an email change using a Change Request object.
    ///
    /// - Parameter request: The email change request containing the new email
    /// - Returns: The result of the change request
    public func request(
        _ request: Identity.Email.Change.Request
            // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
    ) async throws(any Swift.Error) -> Identity.Email.Change.Request.Result {
        // swiftlint:enable no_any_protocol_existential
        return try await self.request(newEmail: request.newEmail)
    }
}

extension Identity.Email.Change.Client {
    /// Convenience method for requesting an email change using an EmailAddress object.
    ///
    /// - Parameter newEmail: The new email address
    /// - Returns: The confirmation response
    public func request(
        _ newEmail: EmailAddress
            // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
    ) async throws(any Swift.Error) -> Identity.Email.Change.Confirmation.Response {
        // swiftlint:enable no_any_protocol_existential
        return try await self.confirm(token: newEmail.rawValue)
    }
}

extension Identity.Email.Change.Client {
    /// Convenience method for confirming an email change using a Confirmation object.
    ///
    /// - Parameter confirm: The confirmation details containing the verification token
    /// - Returns: The confirmation response
    public func confirm(
        _ confirm: Identity.Email.Change.Confirmation
            // swiftlint:disable no_any_protocol_existential - DI witness-closure type erasure ([API-ERR-006]/[#219] class) — pluggable client boundary; see issue #9 disposition
    ) async throws(any Swift.Error) -> Identity.Email.Change.Confirmation.Response {
        // swiftlint:enable no_any_protocol_existential
        return try await self.confirm(token: confirm.token)
    }
}
