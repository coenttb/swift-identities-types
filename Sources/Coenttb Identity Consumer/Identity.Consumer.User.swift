//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 06/02/2025.
//

import Foundation

import Dependencies
@preconcurrency import Vapor
import JWT
import Coenttb_Identity_Shared

extension Identity.Consumer {
    public typealias User = JWT.Payload
//    public struct User: Authenticatable {
//        public let id: UUID
//        public let email: String
//        public let sessionVersion: Int
//        
//        public init(
//            id: UUID,
//            email: String,
//            sessionVersion: Int
//        ) {
//            self.id = id
//            self.email = email
//            self.sessionVersion = sessionVersion
//        }
//    }
}
