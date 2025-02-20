# ``Identity_Provider``

## Overview

@Metadata {
    @DisplayName("Identity Provider")
}

swift-identities provides an API and Client for identity authententication and management via tokens. The purpose of `swift-identities` is to provide the abstract Client and concrete API and associated types as a foundation upon which you can build your identity provider and/or identity consumer.

> Tip: Please see [coenttb-identities](https://github.com/coenttb/coenttb-identities) for an example. 

> Note: Identity is the part of a user that is necessary for to authenticate that user. A common pattern is that of an identity provider and a server that uses that identity provider to authenticate its users (identity consumer). The identity provider can be at id.example.com, while the consumer is example.com, app.example.com, an iOS or android app, or a third party service.

## Quick start

Getting started requires the following steps:
1. Extend `Identity.Provider.Client` and/or `Identity.Consumer.Client` with your custom implementation. We suggest you use `static func`'s named `live`

@Row {
    @Column {
        ```swift
        extension Identity.Provider.Client {
            public static func live(
                ... your custom parameters...
            ) -> Self {
                ... your custom implementation...
            }
        }
        ```
    }
    @Column {
        ```swift
        extension Identity.Consumer.Client {
            public static func live(
                ... your custom parameters...
            ) -> Self {
                ... your custom implementation...
            }
        }
        ```
    }
}

2. Conform `Identity.Provider.Client` and/or `Identity.Consumer.Client` to `DependencyKey`, and use the respective `Identity.Provider.Client.live` and `Identity.Consumer.Client.live` static funcs for the liveValue implementation.

```swift
extension Identity.Provider.Client: DependencyKey {
    return .live(...)
}
```

3. Now you can use the Client anywhere in your server:
```swift
@Dependency(\.identity.provider.client) var client

client.authenticate.credentials(username: "...", password: "...")
```

Depending on your choice of server and database, you will also need to define a HTTP response. This is the 'outer' layer of the identity provider/consumer, and should be concerned with rate limiting and setting headers and cookies.

This is all you need to know to get started with `swift-identities`.

## What is Dependencies?

[Dependencies](https://github.com/pointfreeco/swift-dependencies) is a dependency management library inspired by SwiftUI's "environment". This package uses Dependencies to provide different implementations of Client for use in tests.

## What is URLRouting?

[URLRouting](https://github.com/pointfreeco/swift-url-routing) is a bidirectional URL router with more type safety and less fuss. This package leverages URLRouting to parse URLRequest objects into our API types and generate URLs from them.

## Topics

### Identity Provider

### Identity Consumer

### Essentials


