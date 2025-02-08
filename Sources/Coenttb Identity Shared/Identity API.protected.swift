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
    ) throws -> (any AsyncResponseEncodable)? {
        @Dependency(\.request) var request
        guard let request else { throw Abort.requestUnavailable }
        
        switch api {
        case .authenticate:
            return nil
        case .create:
            return nil
        case .delete:
            try request.auth.require(type)
            return nil
        case .emailChange:
            try request.auth.require(type)
            return nil
        case .logout:
            try request.auth.require(type)
            return nil
        case .reauthorize:
            try request.auth.require(type)
            return nil
        case .password(let password):
            switch password {
            case .reset:
                return nil
            case .change:
                try request.auth.require(type)
                return nil
            }
        case .multifactorAuthentication:
            try request.auth.require(type)
            return nil
        }
    }
}
