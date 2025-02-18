import Coenttb_Identity_Shared
import Dependencies
@preconcurrency import Fluent
import Foundation
import JWT
import RateLimiter
@preconcurrency import Vapor

extension Identity.Provider {
    public struct ApiKeyAuthenticator: AsyncBearerAuthenticator {

        public init(
            
        ) {
            
        }
        
        @Dependency(\.identity.provider.client) var client

        public func authenticate(
            bearer: BearerAuthorization,
            for request: Request
        ) async throws {
            await withDependencies {
                $0.request = request
            } operation: {
                do {
                    try await withDependencies {
                        $0.request = request
                    } operation: {
                        _ = try await client.authenticate.apiKey(bearer.token)
                    }
                } catch {
                    
                }
            }
        }
    }
}
