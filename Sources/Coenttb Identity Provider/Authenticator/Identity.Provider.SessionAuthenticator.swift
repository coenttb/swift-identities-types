////
////  File.swift
////  coenttb-identity
////
////  Created by Coen ten Thije Boonkkamp on 22/01/2025.
////
//
import Dependencies
@preconcurrency import Fluent
import Foundation
@preconcurrency import Vapor
//
//extension Identity.Provider {
//    public struct SessionAuthenticator: AsyncSessionAuthenticator {
//        public typealias User = Database.Identity
//        
//        public init() {}
//        
//        public func authenticate(sessionID: UUID, for request: Request) async throws {
//            guard let identity = try await Database.Identity.find(sessionID, on: request.db)
//            else { return }
//            
//            if let storedVersion = request.session.identityVersion {
//                if storedVersion != identity.sessionVersion {
//                    request.session.unauthenticate(Database.Identity.self)
//                    return
//                }
//            } else {
//                // Handle case where version is missing - could be an old session
//                request.session.unauthenticate(Database.Identity.self)
//                return
//            }
//            identity.lastLoginAt = Date()
//            try await identity.save(on: request.db)
//            
//            request.auth.login(identity)
//            
//            request.session.identityVersion = identity.sessionVersion
//        }
//    }
//}
//
extension Session {
    var identityVersion: Int? {
        get { self.data[Database.Identity.FieldKeys.sessionVersion.description].flatMap(Int.init) }
        set { self.data[Database.Identity.FieldKeys.sessionVersion.description] = newValue.map(String.init) }
    }
}
