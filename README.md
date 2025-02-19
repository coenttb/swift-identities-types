# swift-identity

`swift-identity` is a type-safe, modular authentication framework designed for Swift applications. It provides a comprehensive set of tools for handling user identity, authentication, and account management.

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

This package is currently in active development and is subject to frequent changes. Features and APIs may change without prior notice until a stable release is available.

## Features

- authentication and authorization
- Identity management
- Password reset and recovery
- Email verification
- Session handling
- Secure token management

## Security

- All passwords are securely hashed
- Email verification required for sensitive operations
- Token-based authentication
- Rate limiting support
- CSRF protection

## Installation

You can add `swift-identity` to an Xcode project by including it as a package dependency:

Repository URL: https://github.com/coenttb/swift-identity

For a Swift Package Manager project, add the dependency in your Package.swift file:
```
dependencies: [
  .package(url: "https://github.com/coenttb/swift-identity", branch: "main")
]
```

## Example

Refer to [coenttb/coenttb-identity](https://www.github.com/coenttb/coenttb-identity) for an example of how to use swift-identity.
Refer to [coenttb/coenttb-com-server](https://www.github.com/coenttb/coenttb-com-server) for an example of how to use coenttb-identity.

## Related Projects

* [coenttb/coenttb-identity](https://www.github.com/coenttb/swift-web): Live implementation of swift-identity.
* [coenttb/swift-web](https://www.github.com/coenttb/swift-web): Modular tools to simplify web development in Swift forked from  [pointfreeco/swift-web](https://www.github.com/pointfreeco/swift-web), and updated for use in [coenttb/coenttb-web](https://www.github.com/coenttb/coenttb-web).
* [coenttb/coenttb-com-server](https://www.github.com/coenttb/coenttb-com-server): The backend server for coenttb.com, written entirely in Swift and powered by [Vapor](https://www.github.com/vapor/vapor) and [coenttb-web](https://www.github.com/coenttb/coenttb-web).
* [coenttb/swift-languages](https://www.github.com/coenttb/swift-languages): A cross-platform translation library written in Swift.

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

