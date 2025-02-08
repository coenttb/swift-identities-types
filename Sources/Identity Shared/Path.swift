//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 28/01/2025.
//

import Foundation
import URLRouting

extension Path<PathBuilder.Component<String>> {
    
    nonisolated(unsafe) public static let request = Path {
        "request"
    }
    
    nonisolated(unsafe) public static let api = Path {
        "api"
    }
    
    nonisolated(unsafe) public static let apiKey = Path {
        "api-key"
    }
    
    nonisolated(unsafe) public static let verify = Path {
        "verify"
    }
    
    nonisolated(unsafe) public static let refresh = Path {
        "refresh"
    }
    
    nonisolated(unsafe) public static let access = Path {
        "access"
    }
    
    nonisolated(unsafe) public static let cancel = Path {
        "cancel"
    }
    
    nonisolated(unsafe) public static let confirm = Path {
        "confirm"
    }
    
    nonisolated(unsafe) public static let reauthorization = Path {
        "reauthorization"
    }
    
    nonisolated(unsafe) public static let reauthorize = Path {
        "reauthorize"
    }
    
    nonisolated(unsafe) public static let create = Path {
        "create"
    }
    
    nonisolated(unsafe) public static let authenticate = Path {
        "authenticate"
    }
    nonisolated(unsafe) public static let update = Path {
        "update"
    }
    nonisolated(unsafe) public static let delete = Path {
        "delete"
    }
    nonisolated(unsafe) public static let login = Path {
        "login"
    }
    nonisolated(unsafe) public static let currentUser = Path {
        "current-user"
    }
    nonisolated(unsafe) public static let logout = Path {
        "logout"
    }
    nonisolated(unsafe) public static let password = Path {
        "password"
    }
    nonisolated(unsafe) public static let emailChange = Path {
        "email-change"
    }
    nonisolated(unsafe) public static let emailVerification = Path {
        "email-verification"
    }
    nonisolated(unsafe) public static let reset = Path {
        "reset"
    }
    nonisolated(unsafe) public static let change = Path {
        "change"
    }
}

// MFA specific
extension Path<PathBuilder.Component<String>> {
    nonisolated(unsafe) public static let setup = Path {
        "setup"
    }
    
    nonisolated(unsafe) public static let initialize = Path {
        "initialize"
    }
    
    nonisolated(unsafe) public static let challenge = Path {
        "challenge"
    }
    
    nonisolated(unsafe) public static let recovery = Path {
        "recovery"
    }
    
    nonisolated(unsafe) public static let generate = Path {
        "generate"
    }
    
    nonisolated(unsafe) public static let count = Path {
        "count"
    }
    
    nonisolated(unsafe) public static let configuration = Path {
        "configuration"
    }
    
    nonisolated(unsafe) public static let disable = Path {
        "disable"
    }
    
    nonisolated(unsafe) public static let multifactorAuthentication = Path {
        "multifactor-authentication"
    }
    
    nonisolated(unsafe) public static let manage = Path {
        "manage"
    }
}
