//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import Coenttb_Vapor

extension Identity.API {
    package static func protect<Authenticatable: Vapor.Authenticatable>(
        api: Identity.API,
        with type: Authenticatable.Type
    ) throws {
        @Dependency(\.request) var request
        guard let request else { throw Abort.requestUnavailable }

        switch api {
        case .authenticate(let authenticate):
            switch authenticate {
            case .credentials, .token, .apiKey:
                break
            case .multifactor:
                try request.auth.require(type)

            }

        case .create:
            break
        case .delete:
            try request.auth.require(type)

        case .emailChange:
            try request.auth.require(type)

        case .logout:
            try request.auth.require(type)

        case .reauthorize:
            try request.auth.require(type)

        case .password(let password):
            switch password {
            case .reset:
                break
            case .change:
                try request.auth.require(type)

            }

        }
    }
}
