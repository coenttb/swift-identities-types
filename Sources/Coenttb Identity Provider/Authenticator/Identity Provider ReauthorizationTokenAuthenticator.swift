//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 06/02/2025.
//

import Coenttb_Identity_Shared
import Dependencies
import JWT
@preconcurrency import Vapor

// extension Identity.Provider {
//    public struct RefreshTokenAuthenticator: AsyncMiddleware {
//        public init() {}
//        
//        public func respond(
//            to request: Request,
//            chainingTo next: AsyncResponder
//        ) async throws -> Response {
//            @Dependency(Identity.Provider.Client.self) var client
//            
//            if let refreshToken = request.cookies.reauthorizationToken?.string {
//                do {
//                    let _ = try await client.reauthorize(password: <#T##String#>)
//                    print("successful refresh token")
//                } catch {
//                }
//            }
//            
//            return try await next.respond(to: request)
//        }
//    }
// }
