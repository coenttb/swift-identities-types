//
//  File.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import URLRouting

extension Path<PathBuilder.Component<String>> {

    public static var request: Path<PathBuilder.Component<String>> {
        Path {
            "request"
        }
    }

    public static var api: Path<PathBuilder.Component<String>> {
        Path {
            "api"
        }
    }

    public static var apiKey: Path<PathBuilder.Component<String>> {
        Path {
            "api-key"
        }
    }

    public static var verify: Path<PathBuilder.Component<String>> {
        Path {
            "verify"
        }
    }

    public static var refresh: Path<PathBuilder.Component<String>> {
        Path {
            "refresh"
        }
    }

    public static var access: Path<PathBuilder.Component<String>> {
        Path {
            "access"
        }
    }

    public static var cancel: Path<PathBuilder.Component<String>> {
        Path {
            "cancel"
        }
    }

    public static var confirm: Path<PathBuilder.Component<String>> {
        Path {
            "confirm"
        }
    }

    public static var reauthorization: Path<PathBuilder.Component<String>> {
        Path {
            "reauthorization"
        }
    }

    public static var reauthorize: Path<PathBuilder.Component<String>> {
        Path {
            "reauthorize"
        }
    }

    public static var create: Path<PathBuilder.Component<String>> {
        Path {
            "create"
        }
    }

    public static var authenticate: Path<PathBuilder.Component<String>> {
        Path {
            "authenticate"
        }
    }
    public static var update: Path<PathBuilder.Component<String>> {
        Path {
            "update"
        }
    }
    public static var delete: Path<PathBuilder.Component<String>> {
        Path {
            "delete"
        }
    }
    public static var login: Path<PathBuilder.Component<String>> {
        Path {
            "login"
        }
    }
    public static var credentials: Path<PathBuilder.Component<String>> {
        Path {
            "credentials"
        }
    }
    public static var logout: Path<PathBuilder.Component<String>> {
        Path {
            "logout"
        }
    }
    public static var password: Path<PathBuilder.Component<String>> {
        Path {
            "password"
        }
    }
    public static var email: Path<PathBuilder.Component<String>> {
        Path {
            "email"
        }
    }
    public static var change: Path<PathBuilder.Component<String>> {
        Path {
            "change"
        }
    }
    public static var verification: Path<PathBuilder.Component<String>> {
        Path {
            "verification"
        }
    }
    public static var reset: Path<PathBuilder.Component<String>> {
        Path {
            "reset"
        }
    }

    public static var mfa: Path<PathBuilder.Component<String>> {
        Path {
            "reset"
        }
    }

    public static var oauth: Path<PathBuilder.Component<String>> {
        Path {
            "reset"
        }
    }
}

// MFA specific
extension Path<PathBuilder.Component<String>> {
    public static var setup: Path<PathBuilder.Component<String>> {
        Path {
            "setup"
        }
    }

    public static var initialize: Path<PathBuilder.Component<String>> {
        Path {
            "initialize"
        }
    }

    public static var challenge: Path<PathBuilder.Component<String>> {
        Path {
            "challenge"
        }
    }

    public static var recovery: Path<PathBuilder.Component<String>> {
        Path {
            "recovery"
        }
    }

    public static var generate: Path<PathBuilder.Component<String>> {
        Path {
            "generate"
        }
    }

    public static var count: Path<PathBuilder.Component<String>> {
        Path {
            "count"
        }
    }

    public static var configuration: Path<PathBuilder.Component<String>> {
        Path {
            "configuration"
        }
    }

    public static var disable: Path<PathBuilder.Component<String>> {
        Path {
            "disable"
        }
    }

    public static var multifactor: Path<PathBuilder.Component<String>> {
        Path {
            "multifactor"
        }
    }

    public static var manage: Path<PathBuilder.Component<String>> {
        Path {
            "manage"
        }
    }
}
