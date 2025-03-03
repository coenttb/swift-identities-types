//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import Coenttb_Vapor

extension Identity.API {
    package static func protect<Authenticatable: Vapor.Authenticatable>(
        api: Identity.API,
        with type: Authenticatable.Type
    ) throws {
        
        switch api {
        case .authenticate(let authenticate):
            switch authenticate {
            case .credentials, .token, .apiKey:
                break

            }

        case .create:
            break
        case .delete:
            @Dependency(\.request) var request
            guard let request else { throw Abort.requestUnavailable }
            try request.auth.require(type)

        case .email:
            @Dependency(\.request) var request
            guard let request else { throw Abort.requestUnavailable }
            try request.auth.require(type)

        case .logout:
            @Dependency(\.request) var request
            guard let request else { throw Abort.requestUnavailable }
            try request.auth.require(type)

        case .reauthorize:
            @Dependency(\.request) var request
            guard let request else { throw Abort.requestUnavailable }
            try request.auth.require(type)

        case .password(let password):
            switch password {
            case .reset:
                break
            case .change:
                @Dependency(\.request) var request
                guard let request else { throw Abort.requestUnavailable }
                try request.auth.require(type)

            }

        }
    }
}
