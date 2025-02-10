//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 06/02/2025.
//


import Identity_Consumer
import Coenttb_Identity_Shared
import Coenttb_Vapor
import JWT

extension Identity.Consumer {
   public struct AccessTokenAuthenticator: AsyncMiddleware {
       public init() {}
       
       @Dependency(Identity.Consumer.Client.self) var client
       
       public func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
           if let token = request.cookies["access_token"]?.string {
               try await withDependencies {
                   $0.request = request
               } operation: {
                   try await client.authenticate.token.access(token: token)           }
               }
           return try await next.respond(to: request)
       }
   }
}
