//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 05/02/2025.
//

import Foundation

public enum JWT {}




// Example usage in routes:
/*
 
 // Configure JWT
 try app.configureJWT()
 
 // Login endpoint that returns JWT
 app.post("login") { req async throws -> JWTResponse in
     let identity = try req.auth.require(Database.Identity.self)
     return try identity.generateJWTResponse(req: req)
 }
 
 // Protected route using JWT authentication
 let protected = app.grouped(
     JWTAuthenticator(),
     Database.Identity.guardMiddleware()
 )
 
 protected.get("me") { req async throws -> Database.Identity in
     try req.auth.require(Database.Identity.self)
 }
 
 */
