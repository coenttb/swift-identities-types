# CLAUDE.md - swift-identities-types

This file provides comprehensive guidance to Claude Code when working with the swift-identities-types package.

## Package Overview

swift-identities-types defines the complete type system for identity management across client and server applications. It follows a domain-first architecture pattern where business capabilities are primary, with technical implementations as nested types.

## Core Architecture Pattern

### Domain-First Organization

The package follows the pattern: `Domain.SubDomain.TechnicalFeature`

```swift
// Good - Domain first
Identity.Authentication.Client
Identity.MFA.TOTP.API
Identity.Password.Reset.Router

// Bad - Technical first (old pattern we moved away from)
Identity.Client.Authentication
Identity.MFA.API.TOTP
```

### Struct-Based Domain Pattern

**Key Principle**: Domains are structs that contain both client and router properties, NOT nested clients within clients.

```swift
// Current Pattern - Domains as structs with properties
extension Identity {
    public struct Authentication {
        public var client: Identity.Authentication.Client      // Operations
        public var router: Identity.Authentication.Route.Router // Routing
        public var token: Identity.Authentication.Token.Client  // Subdomain
        
        public init(
            client: Identity.Authentication.Client,
            router: Identity.Authentication.Route.Router = .init(),
            token: Identity.Authentication.Token.Client
        ) {
            self.client = client
            self.router = router
            self.token = token
        }
    }
}

// Old Pattern (avoid) - Nested clients
extension Identity.Client {
    public var authenticate: Identity.Client.Authenticate.Client { ... }
}
```

## File Organization

```
Sources/IdentitiesTypes/
├── {Domain}/                                          # e.g., Authentication/
│   ├── Identity.{Domain}.swift                       # Domain struct with client & router
│   ├── Identity.{Domain}.Client.swift                # @DependencyClient operations
│   ├── Identity.{Domain}.API.swift                   # API enum cases and Router
│   ├── Identity.{Domain}.Route.swift                 # Route enum for navigation
│   ├── Identity.{Domain}.View.swift                  # View enum for UI routing
│   └── {SubDomain}/                                  # e.g., Token/
│       ├── Identity.{Domain}.{SubDomain}.swift       # Subdomain struct
│       ├── Identity.{Domain}.{SubDomain}.Client.swift
│       └── Identity.{Domain}.{SubDomain}.API.swift
```

## Key Patterns

### 1. Domain Struct Pattern

Every domain with operations must have:
- `client` property for operations
- `router` property for API routing
- Subdomain properties if applicable
- Initializer with default router

```swift
public struct DomainName {
    public var client: Identity.DomainName.Client
    public var router: Identity.DomainName.Route.Router  // Or API.Router if no Route
    public var subdomain: Identity.DomainName.SubDomain  // If has subdomains
    
    public init(
        client: Identity.DomainName.Client,
        router: Identity.DomainName.Route.Router = .init(),
        subdomain: Identity.DomainName.SubDomain
    ) {
        self.client = client
        self.router = router
        self.subdomain = subdomain
    }
}
```

### 2. Router Pattern

**Important**: Use the appropriate router type:
- If domain has `Route.swift` → use `Route.Router`
- If domain only has `API.swift` → use `API.Router`
- Some domains have both for different purposes

```swift
// Authentication uses Route.Router
public var router: Identity.Authentication.Route.Router

// MFA subdomains use API.Router
public var router: Identity.MFA.TOTP.API.Router
```

### 3. Data Type Organization

Avoid naming conflicts between subdomains and data types:

```swift
// Problem: Both subdomain and data type named "Status"
public struct Status { var client: ... }  // Subdomain
public struct Status: Codable { ... }     // Data type - CONFLICT!

// Solution: Nest data types within subdomains
public struct Status { var client: ... }               // Subdomain
public struct Response: Codable { ... }                // Data type in Status namespace
// Usage: Identity.MFA.Status.Response
```

### 4. Client Pattern

All clients use @DependencyClient with clear async throws signatures:

```swift
@DependencyClient
public struct Client: @unchecked Sendable {
    @DependencyEndpoint
    public var someOperation: (Parameters) async throws -> Response
    
    // Optional: Add callAsFunction for primary operation
    public func callAsFunction() async throws -> Response {
        try await self.primaryOperation()
    }
}
```

### 5. API and Router Pattern

```swift
@CasePathable
@dynamicMemberLookup
public enum API: Equatable, Sendable {
    case operation1(Parameters1)
    case operation2(Parameters2)
}

public struct Router: ParserPrinter, Sendable {
    public init() {}
    
    public var body: some URLRouting.Router<API> {
        OneOf {
            Route(.case(API.operation1)) {
                Method.post
                Path.operation1
                Body(.json(Parameters1.self))
            }
        }
    }
}
```

## Domain Structure Reference

### Top-Level Domains
- `Authentication` - Has client, router, token subdomain
- `Creation` - Has client, router
- `Deletion` - Has client, router
- `Email` - Has change subdomain
- `OAuth` - Has client, router
- `Password` - Has reset and change subdomains
- `Logout` - Has client, router
- `Reauthorization` - Has client, router (uses Request.Router)
- `MFA` - Container for MFA subdomains

### MFA Subdomains
Each has client and router:
- `MFA.TOTP`
- `MFA.SMS`
- `MFA.Email`
- `MFA.WebAuthn`
- `MFA.BackupCodes`
- `MFA.Status`

### Special Cases

#### Password Domain
Password has two subdomains (Reset and Change), each with their own API and Router:

```swift
public struct Password {
    public var change: Identity.Password.Change
    public var reset: Identity.Password.Reset
}

public struct Reset {
    public var client: Identity.Password.Reset.Client
    public var router: Identity.Password.Reset.API.Router
}
```

#### Reauthorization
Uses typealias for API, router comes from Request:

```swift
public typealias API = Identity.Reauthorization.Request
// Router is Identity.Reauthorization.Request.Router
```

## Migration Guide for swift-identities

When refactoring swift-identities to match these patterns:

### 1. Identify Current Structure
- Map all `Identity.Client.X` to `Identity.X.Client`
- Map all `Identity.API.X` to `Identity.X.API`

### 2. Create Domain Structs
Replace nested clients with domain structs containing client and router properties.

### 3. Update File Names
- `Identity.Client.Authentication.swift` → `Identity.Authentication.Client.swift`
- `Identity.API.Authentication.swift` → `Identity.Authentication.API.swift`

### 4. Maintain Backward Compatibility
Create deprecated typealiases during transition:

```swift
@available(*, deprecated, renamed: "Identity.Authentication.Client")
public typealias AuthenticationClient = Identity.Authentication.Client
```

### 5. Update Imports
Change import statements and type references throughout the codebase.

## Common Pitfalls to Avoid

1. **Don't nest clients within clients** - Use struct properties instead
2. **Don't forget routers** - Every domain with a client should have a router
3. **Watch for naming conflicts** - Especially with data types vs subdomains
4. **Use correct router type** - Route.Router vs API.Router
5. **Include initializers** - All domain structs need proper init methods

## Testing Patterns

Use Swift Testing framework (not XCTest):
```swift
import Testing

@Test func testAuthentication() async throws {
    let client = Identity.Authentication.Client()
    // Test implementation
}
```

## Dependencies

- `CasePaths` - For @CasePathable enums
- `Dependencies` - For @DependencyClient
- `ServerFoundation` - For URLRouting and server types
- `EmailAddress` - For validated email types

## Version and Compatibility

- Swift 6.0+ with strict concurrency
- All types are Sendable
- Designed for both client and server use
- iOS 17.0+, macOS 14.0+
