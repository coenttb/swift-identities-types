//
//  File.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import Foundation
import URLRouting

/// Retroactively conforms URLRequestData to the Sendable protocol.
/// This allows URLRequestData to be safely used across actor and task boundaries.
///
/// While URLRequestData's contents are generally thread-safe, we mark this as @unchecked
/// since we cannot verify the sendability of all possible request data.
///
/// - Note: This conformance has been tested in production use cases without issues.
extension URLRequestData: @retroactive @unchecked Sendable {}

/// Conditionally conforms AnyParserPrinter to Sendable when its generic parameters are Sendable.
///
/// - Important: This is marked as @unchecked because while the generic parameters may be Sendable,
/// AnyParserPrinter contains closures that need to be verified for thread safety independently.
/// These closures would need to be marked with @Sendable to guarantee full thread safety.
///
/// - Note: Added in response to discussion about URL routing type safety across concurrent contexts.
extension AnyParserPrinter: @unchecked @retroactive Sendable where Input: Sendable, Output: Sendable {}

/// Conditionally conforms Path to Sendable when its generic parameters are Sendable.
///
/// Path represents a URL path component in the routing system. While its structure is generally
/// thread-safe when the generic parameters are Sendable, we mark it as @unchecked since
/// we cannot verify the thread safety of all possible path configurations.
///
/// - Note: This conformance enables Path to be used safely in concurrent URL routing contexts
/// while acknowledging that full verification requires runtime checks.
extension Path: @unchecked @retroactive Sendable where Input: Sendable, Output: Sendable {}

extension Path<PathBuilder.Component<String>> {    

    public static let request = Path {
        "request"
    }
    
    public static let api = Path {
        "api"
    }

    public static let apiKey = Path {
        "api-key"
    }

    public static let verify = Path {
        "verify"
    }

    public static let refresh = Path {
        "refresh"
    }

    public static let access = Path {
        "access"
    }

    public static let cancel = Path {
        "cancel"
    }

    public static let confirm = Path {
        "confirm"
    }

    public static let reauthorization = Path {
        "reauthorization"
    }

    public static let reauthorize = Path {
        "reauthorize"
    }

    public static let create = Path {
        "create"
    }

    public static let authenticate = Path {
        "authenticate"
    }
    public static let update = Path {
        "update"
    }
    public static let delete = Path {
        "delete"
    }
    public static let login = Path {
        "login"
    }
    public static let credentials = Path {
        "credentials"
    }
    public static let logout = Path {
        "logout"
    }
    public static let password = Path {
        "password"
    }
    public static let email = Path {
        "email"
    }
    public static let change = Path {
        "change"
    }
    public static let verification = Path {
        "verification"
    }
    public static let reset = Path {
        "reset"
    }
}

// MFA specific
extension Path<PathBuilder.Component<String>> {
    public static let setup = Path {
        "setup"
    }

    public static let initialize = Path {
        "initialize"
    }

    public static let challenge = Path {
        "challenge"
    }

    public static let recovery = Path {
        "recovery"
    }

    public static let generate = Path {
        "generate"
    }

    public static let count = Path {
        "count"
    }

    public static let configuration = Path {
        "configuration"
    }

    public static let disable = Path {
        "disable"
    }

    public static let multifactor = Path {
        "multifactor"
    }

    public static let manage = Path {
        "manage"
    }
}
