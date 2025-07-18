import Coenttb_Identity_Shared
import Coenttb_Vapor
import Coenttb_Web
import Dependencies
import EmailAddress
import Identities
import JWT
import RateLimiter

extension Identity.Consumer.Client {
    public static func live(

    ) -> Self {

        @Dependency(\.identity.consumer.client) var client

        return .init(
            authenticate: .live(),
            logout: {
                @Dependency(\.request) var request
                guard let request else { throw Abort.requestUnavailable }
                request.auth.logout(JWT.Token.Access.self)
            },
            reauthorize: { password in
                try await client.handleRequest(
                    for: .reauthorize(.init(password: password)),
                    decodingTo: JWT.Token.self
                )
            },
            create: .live(),
            delete: .live(),
            email: .live(),
            password: .live()
        )
    }
}

extension Identity.Consumer.Client {
    public enum Error: Swift.Error {
        case requestError
        case printError
    }
}
