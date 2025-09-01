# swift-identities-types

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![Version](https://img.shields.io/badge/version-0.1.0-green.svg)](https://github.com/coenttb/swift-identities-types/releases)

`swift-identities-types` provides type-safe, modular types and protocols for identity authentication and management.

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

This package is currently in active development and is subject to frequent changes. Features and APIs may change without prior notice until a stable release is available.

## Features

- Identity creation and email verification
- Identity authentication via credentials, tokens, and api-keys
- Password reset and change
- Email change
- Token management

## Installation

You can add `swift-identities-types` to an Xcode project by including it as a package dependency:

Repository URL: https://github.com/coenttb/swift-identities-types

For a Swift Package Manager project, add the dependency in your Package.swift file:
```swift
dependencies: [
  .package(url: "https://github.com/coenttb/swift-identities-types", from: "0.1.0")
]
```

## Usage

This package provides the core types and protocols. For a complete implementation, use:
- [swift-identities](https://github.com/coenttb/swift-identities) - Complete authentication system
- [swift-identities-mailgun](https://github.com/coenttb/swift-identities-mailgun) - Email integration

## Related Projects

* [swift-identities](https://github.com/coenttb/swift-identities): Complete authentication system implementation
* [swift-identities-mailgun](https://github.com/coenttb/swift-identities-mailgun): Mailgun email integration for identities
* [coenttb-com-server](https://github.com/coenttb/coenttb-com-server): Example production usage

## Feedback is much appreciated!

If you’re working on your own Swift project, feel free to learn, fork, and contribute.

Got thoughts? Found something you love? Something you hate? Let me know! Your feedback helps make this project better for everyone. Open an issue or start a discussion—I’m all ears.

> [Subscribe to my newsletter](http://coenttb.com/en/newsletter/subscribe)
>
> [Follow me on X](http://x.com/coenttb)
> 
> [Link on Linkedin](https://www.linkedin.com/in/tenthijeboonkkamp)

## License

This project is licensed by coenttb under the Apache 2.0 License. See [LICENSE](LICENSE) for details.
