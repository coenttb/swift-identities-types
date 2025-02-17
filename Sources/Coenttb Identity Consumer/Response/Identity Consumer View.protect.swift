//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import Coenttb_Vapor
import Favicon
import Identity_Consumer

extension Identity.Consumer.View {
    package static func protect<Authenticatable: Vapor.Authenticatable>(
        view: Identity.Consumer.View,
        with type: Authenticatable.Type,
        createProtectedRedirect: URL,
        loginProtectedRedirect: URL
    ) throws {
        @Dependency(\.request) var request
        guard let request else { throw Abort.requestUnavailable }

        switch view {
        case .create:
            if !request.auth.has(type) { throw Abort(.forbidden) }

        case .delete:
            try request.auth.require(type)

        case .authenticate(let authenticate):
            switch authenticate {
            case .credentials:
                if !request.auth.has(type) { throw Abort(.forbidden) }
                
            case .multifactor:
                try request.auth.require(type)
            }

        case .logout:
            if !request.auth.has(type) {
                throw Abort(.forbidden)
            }

        case .password(let password):
            switch password {
            case .reset:
                break
                
            case .change:
                try request.auth.require(type)
            }

        case .emailChange:
            try request.auth.require(type)
        }
    }
}
