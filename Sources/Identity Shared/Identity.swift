//
//  File.swift
//  swift-identity
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
///
/// The namespace is split into two main interfaces:
/// - ``Identity/Provider``: Server-side identity management and authentication
/// - ``Identity/Consumer``: Client-side identity operations and user sessions
///
/// Both interfaces share common types through ``Identity_Shared`` to ensure
/// consistency between client and server communications.
public enum Identity {}
