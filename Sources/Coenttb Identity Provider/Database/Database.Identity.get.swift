//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 01/02/2025.
//

import Coenttb_Server
import Coenttb_Vapor
import Coenttb_Web
import Fluent
@preconcurrency import FluentKit
import Foundation
import Identities
import Coenttb_Fluent

extension Database.Identity {
    public enum Get {
        public enum Identifier {
            case id(UUID)
            case email(String)
            case auth

            public static func email(_ email: EmailAddress) -> Self {
                .email(email.rawValue)
            }
        }
    }

    public static func get(
        by identifier: Database.Identity.Get.Identifier,
        on database: Fluent.Database = {
            @Dependency(\.database) var database
            return database
        }()
    ) async throws -> Database.Identity {

        switch identifier {
        case .id(let id):
            guard let identity = try await Database.Identity.find(id, on: database)
            else { throw Abort(.notFound, reason: "Identity not found") }
            return identity

        case .email(let email):
            guard let identity = try await Database.Identity.query(on: database)
                .filter(\.$email == email)
                .first()
            else {
                throw Abort(.notFound, reason: "Identity not found")
            }
            return identity

        case .auth:
            @Dependency(\.request) var request
            guard let request
            else {
                print("Request not available for Identity.get(.auth, ...)")
                throw Abort.requestUnavailable
            }

            guard let identity = request.auth.get(Database.Identity.self)
            else { throw Abort(.unauthorized, reason: "Not authenticated") }
            
            guard let id = identity.id
            else { throw Abort(.internalServerError, reason: "Invalid identity state") }
            
            return try await Database.Identity.get(by: .id(id), on: database)
        }
    }
}
