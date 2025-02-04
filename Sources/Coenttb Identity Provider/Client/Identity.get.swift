//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 01/02/2025.
//

import Foundation
import Coenttb_Web
import Coenttb_Server
import Fluent
import Vapor
import Identity_Provider
import FluentKit

extension Identity {
    public enum Get {
        public enum Identifier {
            case id(UUID)
            case email(String)
            case auth
        }
    }
    
    public static func get(
        by identifier: Identity.Get.Identifier,
        on database: Database
    ) async throws -> Identity {
        
        switch identifier {
        case .id(let id):
            guard let identity = try await Identity.find(id, on: database) else {
                throw Abort(.notFound, reason: "Identity not found")
            }
            return identity
            
        case .email(let email):
            guard let identity = try await Identity.query(on: database)
                .filter(\.$email == email)
                .first() else {
                throw Abort(.notFound, reason: "Identity not found")
            }
            return identity
            
        case .auth:
            @Dependency(\.request) var request
            guard let request else { throw Abort.requestUnavailable }
            
            guard let identity = request.auth.get(Identity.self) else {
                throw Abort(.unauthorized, reason: "Not authenticated")
            }
            guard let id = identity.id else {
                throw Abort(.internalServerError, reason: "Invalid identity state")
            }
            return try await Identity.get(by: .id(id), on: database)
        }
    }
}
