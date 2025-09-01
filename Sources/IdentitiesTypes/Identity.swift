//
//  Identity.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

/// A namespace for managing identity and authentication in a client-server architecture.
///
/// The Identity namespace provides a comprehensive set of tools for handling identity authentication
/// and identity management through both provider and consumer interfaces. It supports:
///
/// - Identity authentication via credentials, tokens, and API keys
/// - Identity creation and verification flows
/// - Password management (reset, change)
/// - Email management and verification
/// - Session management (login/logout)
///
/// Example of authenticating a user:
/// ```swift
/// let client = Identity.Client(...)
/// let response = try await client.login(
///   username: "user@example.com",
///   password: "password123"
/// )
/// ```
public enum Identity {}
