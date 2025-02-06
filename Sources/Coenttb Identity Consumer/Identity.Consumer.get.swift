import Coenttb_Identity_Shared
import Vapor
import Dependencies
import JWT

extension Identity.Consumer.User {
    public enum Get {
        public enum Identifier {
            case auth
        }
    }
    
    public static func get(
        by identifier: Self.Get.Identifier = .auth
    ) async throws -> Self {
        @Dependency(\.request) var request
        switch identifier {
        case .auth:
            guard let user = request?.auth.get(Identity.Consumer.User.self) else {
                throw Abort(.unauthorized, reason: "Not authenticated")
            }
            return user
        }
    }
}
