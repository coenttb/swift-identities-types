# swift-identities-types

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-0.1.0-green.svg)](https://github.com/coenttb/swift-identities-types/releases)
[![CI](https://github.com/coenttb/swift-identities-types/workflows/CI/badge.svg)](https://github.com/coenttb/swift-identities-types/actions/workflows/ci.yml)

Type-safe Swift definitions for identity authentication and management with dependency injection and URL routing support.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage Examples](#usage-examples)
  - [Authentication](#authentication)
  - [Identity Creation](#identity-creation)
  - [Password Management](#password-management)
  - [Email Management](#email-management)
  - [Identity Deletion](#identity-deletion)
  - [Reauthorization](#reauthorization)
  - [Type-Safe URL Routing](#type-safe-url-routing)
  - [Multi-Factor Authentication](#multi-factor-authentication-optional)
  - [Testing with Mock Clients](#testing-with-mock-clients)
- [Architecture](#architecture)
- [Requirements](#requirements)
- [Related Packages](#related-packages)
- [Contributing](#contributing)
- [License](#license)

## Overview

`swift-identities-types` provides comprehensive type definitions for building identity management systems, including:

- 🔐 **Authentication**: Credentials, tokens, API keys, and OAuth
- 👤 **Identity Creation**: Two-step creation with email verification
- 🔑 **Password Management**: Reset and change flows
- 📧 **Email Management**: Email change with confirmation
- 🗑️ **Identity Deletion**: Request and confirm deletion with safety checks
- 🔒 **Reauthorization**: Token-based sensitive operation verification
- 🔢 **Multi-Factor Authentication**: TOTP, SMS, Email, WebAuthn, and backup codes
- 🛣️ **Type-Safe Routing**: URLRouting integration for compile-time route validation
- 🔌 **Dependency Injection**: Using swift-dependencies for testability

This is a types-only package. For complete implementations, see the Related Packages section below.

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/coenttb/swift-identities-types", from: "0.1.0")
]
```

## Quick Start

### Import the Module

```swift
import IdentitiesTypes
```

### Using the Main Identity Type

The `Identity` type provides access to all identity management operations through a unified interface:

```swift
@Dependency(\.identity) var identity

// Authenticate with credentials
let response = try await identity.login(
    username: "user@example.com",
    password: "password123"
)

// Create new identity
try await identity.create.request(
    email: "new@example.com",
    password: "securePassword123"
)
try await identity.create.verify(
    email: "new@example.com",
    token: "verification-token"
)
```

## Usage Examples

### Authentication

#### Credentials-Based Authentication

```swift
import IdentitiesTypes

@Dependency(\.identity) var identity

// Using convenience method
let response = try await identity.login(
    username: "user@example.com",
    password: "password123"
)
print("Access token: \(response.accessToken)")
print("Refresh token: \(response.refreshToken)")

// Using credentials object
let credentials = Identity.Authentication.Credentials(
    username: "user@example.com",
    password: "password123"
)
let response = try await identity.authenticate.credentials(credentials)
```

#### Token-Based Authentication

```swift
// Validate access token
try await identity.login(accessToken: "jwt-access-token")

// Refresh expired token
let newTokens = try await identity.login(refreshToken: "jwt-refresh-token")
```

#### API Key Authentication

```swift
// Authenticate with API key
let response = try await identity.login(apiKey: "api-key-string")
```

### Identity Creation

The creation process is a two-step flow with email verification:

```swift
// Step 1: Request identity creation
try await identity.create.request(
    email: "new@example.com",
    password: "securePassword123"
)

// Step 2: Verify email with token
try await identity.create.verify(
    email: "new@example.com",
    token: "verification-token-from-email"
)

// Now the user can authenticate
let response = try await identity.login(
    username: "new@example.com",
    password: "securePassword123"
)
```

### Password Management

#### Password Reset (Forgot Password)

```swift
// Step 1: Request password reset
try await identity.password.reset.request(
    email: "user@example.com"
)

// Step 2: Confirm with token from email
try await identity.password.reset.confirm(
    newPassword: "newSecurePassword123",
    token: "reset-token-from-email"
)
```

#### Password Change (Authenticated User)

```swift
// Change password while authenticated
try await identity.password.change.request(
    currentPassword: "currentPassword123",
    newPassword: "newSecurePassword456"
)
```

### Email Management

```swift
// Request email change
let result = try await identity.email.change.request(
    newEmail: "newemail@example.com"
)

// Confirm email change with token
let response = try await identity.email.change.confirm(
    token: "confirmation-token-from-email"
)
// Response contains new access and refresh tokens
```

### Identity Deletion

```swift
// Request deletion (requires recent authentication)
try await identity.delete.request(
    reauthToken: "fresh-auth-token"
)

// Confirm deletion (irreversible)
try await identity.delete.confirm()

// Or cancel the deletion request
try await identity.delete.cancel()
```

### Reauthorization

For sensitive operations requiring fresh authentication:

```swift
import JWT

// Reauthorize with password
let reauthToken: JWT = try await identity.reauthorize.reauthorize(
    password: "currentPassword123"
)

// Use the reauth token for sensitive operations
try await identity.delete.request(
    reauthToken: reauthToken.compactSerialization()
)
```

### Type-Safe URL Routing

Generate and parse URLs with compile-time safety:

```swift
@Dependency(\.identity.router) var router

// Generate URL for login API
let api: Identity.API = .authenticate(.credentials(
    .init(username: "user@example.com", password: "password123")
))
let request = try router.request(for: .api(api))
// Produces: POST /api/authenticate

// Generate URL for password reset view
let viewRoute = Identity.Route.passwordReset
let viewRequest = try router.request(for: viewRoute)
// Produces: GET /password/reset/request

// Parse incoming request
let match = try router.match(request: incomingRequest)
if match.is(\.authenticate.api.credentials) {
    let credentials = match.authenticate?.api?.credentials
    // Handle credential authentication
}
```

### Multi-Factor Authentication (Optional)

When MFA is enabled, the identity provides access to MFA operations:

```swift
if let mfa = identity.mfa {
    // Check MFA status
    let status = try await mfa.status.client.get()

    // Setup TOTP (authenticator app)
    let secret = try await mfa.totp.client.setup()
    try await mfa.totp.client.verify(code: "123456")

    // Generate backup codes
    let codes = try await mfa.backupCodes.client.generate()
}
```

### Testing with Mock Clients

Create mock implementations for testing:

```swift
import Testing
import DependenciesTestSupport

@Test
func testAuthentication() async throws {
    // Use test dependency key
    try await Identity._TestDatabase.Helper.withIsolatedDatabase {
        @Dependency(\.identity) var identity

        // Create test user
        try await identity.create.request(
            email: "test@example.com",
            password: "testPassword123"
        )
        try await identity.create.verify(
            email: "test@example.com",
            token: "verification-token-test@example.com"
        )

        // Test authentication
        let response = try await identity.login(
            username: "test@example.com",
            password: "testPassword123"
        )

        #expect(!response.accessToken.isEmpty)
        #expect(!response.refreshToken.isEmpty)
    }
}
```

## Architecture

### Domain-First Organization

The package follows a domain-first architecture where business capabilities are primary:

```swift
Identity                              // Main namespace
├── authenticate: Authentication      // Authentication operations
│   ├── client: Client               // Authentication client
│   ├── token: Token.Client          // Token operations
│   └── router: Router<Route>        // URL routing
├── create: Creation                  // Identity creation
├── delete: Deletion                  // Identity deletion
├── email: Email                      // Email management
├── password: Password                // Password operations
│   ├── reset: Reset                 // Password reset flow
│   └── change: Change               // Password change flow
├── logout: Logout                    // Session termination
├── reauthorize: Reauthorization     // Fresh auth for sensitive ops
├── mfa: MFA?                        // Optional MFA support
│   ├── totp: TOTP                   // Authenticator app
│   ├── sms: SMS                     // SMS verification
│   ├── email: Email                 // Email verification
│   ├── webauthn: WebAuthn           // Security keys
│   ├── backupCodes: BackupCodes     // Recovery codes
│   └── status: Status               // MFA status queries
└── oauth: OAuth?                     // Optional OAuth support
```

Each domain contains:
- **Client**: Operations interface using @DependencyClient
- **Router**: Type-safe URL routing using URLRouting
- **API**: API endpoint definitions
- **Route**: Combined API and View routes
- **Request/Response types**: Strongly-typed data models

### Type Safety

All types are:
- `Sendable` for Swift 6 strict concurrency
- `Codable` for JSON serialization
- `Equatable` for testing
- Validated at compile-time with URLRouting

## Requirements

- Swift 6.0+
- macOS 14.0+ / iOS 17.0+
- Strict concurrency mode enabled

## Related Packages

- **[swift-identities](https://github.com/coenttb/swift-identities)**: The Swift library for identity authentication and management
- **[swift-authenticating](https://github.com/coenttb/swift-authenticating)**: A Swift package for type-safe HTTP authentication with URL routing integration
- **[swift-server-foundation](https://github.com/coenttb/swift-server-foundation)**: A Swift package with tools to simplify server development
- **[swift-dependencies](https://github.com/pointfreeco/swift-dependencies)**: A dependency management library inspired by SwiftUI's "environment"
- **[swift-jwt](https://github.com/coenttb/swift-jwt)**: A Swift package for creating, signing, and verifying JSON Web Tokens

## Contributing

Contributions are welcome. Please open an issue or submit a pull request.

## License

This project is licensed under the Apache 2.0 License. See [LICENSE](LICENSE) for details.
