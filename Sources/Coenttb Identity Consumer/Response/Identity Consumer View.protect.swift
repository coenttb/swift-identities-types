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
    ) throws -> (any AsyncResponseEncodable)? {
        @Dependency(\.request) var request
        guard let request else { throw Abort.requestUnavailable }
        
        switch view {
        case .create:
            return request.auth.has(type)
            ? request.redirect(to: createProtectedRedirect.relativePath)
            : nil
            
        case .delete:
            try request.auth.require(type)
            return nil
            
        case .authenticate(let authenticate):
            switch authenticate {
            case .credentials:
                return request.auth.has(type)
                ? request.redirect(to: loginProtectedRedirect.relativePath)
                : nil
            case .multifactor(_):
                try request.auth.require(type)
                return nil
            }
            
        case .logout:
//            try request.auth.require(type)
            return nil
            
        case .password(let password):
            switch password {
            case .reset:
                return nil
                
            case .change:
                try request.auth.require(type)
                return nil
            }
            
        case .emailChange:
            try request.auth.require(type)
            return nil

        }
    }
}
