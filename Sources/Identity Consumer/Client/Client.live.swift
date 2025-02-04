import Coenttb_Web
import Identity_Shared
import Dependencies
import EmailAddress

extension Identity.Consumer.Client {
    public static func live(
        provider: Identity.Consumer.Client.Live.Provider,
        makeRequest: (AnyParserPrinter<URLRequestData, Identity.API>) -> (_ route: Identity.API) throws -> URLRequest = Identity.Consumer.Client.Live.makeRequest
    ) -> Self {
        
        let apiRouter = Identity.API.Router().baseURL(provider.baseURL.absoluteString).eraseToAnyParserPrinter()
        
        let makeRequest = makeRequest(apiRouter)
        
        @Dependency(URLRequest.Handler.self) var handleRequest
        
        return .init(
            create: .init(
                request: { email, password in
                    try await handleRequest(
                        for: makeRequest(.create(.request(.init(email: email, password: password))))
                    )
                },
                verify: { email, token in
                    try await handleRequest(
                        for: makeRequest(.create(.verify(.init(email: email, token: token))))
                    )
                }
            ),
            delete: .init(
                request: { /*userId, */reauthToken in
                    try await handleRequest(
                        for: makeRequest(.delete(.request(.init(/*userId: String(userId),*/ reauthToken: reauthToken))))
                    )
                },
                cancel: { /*userId in*/
                    try await handleRequest(
                        for: makeRequest(.delete(.cancel/*(.init(/*userId: String(userId)*/))*/))
                    )
                }
            ),
            login: { email, password in
                try await handleRequest(
                    for: makeRequest(.login(.init(email: email, password: password)))
                )
            },
//            currentUser: {
//                try await handleRequest(
//                    for: makeRequest(.currentUser),
//                    decodingTo: User.self
//                )
//            },
//            update: { user in
//                try await handleRequest(
//                    for: makeRequest(.update(user)),
//                    decodingTo: User.self
//                )
//            },
            logout: {
                try await handleRequest(
                    for: makeRequest(.logout)
                )
            },
            password: .init(
                reset: .init(
                    request: { email in
                        try await handleRequest(
                            for: makeRequest(.password(.reset(.request(.init(email: email)))))
                        )
                    },
                    confirm: { token, newPassword in
                        try await handleRequest(
                            for: makeRequest(.password(.reset(.confirm(.init()))))
                        )
                    }
                ),
                change: .init(
                    request: { currentPassword, newPassword in
                        try await handleRequest(
                            for: makeRequest(.password(.change(.request(change: .init(currentPassword: currentPassword, newPassword: newPassword)))))
                        )
                    }
                )
            ),
            emailChange: .init(
                request: { newEmail in
                    guard let newEmail = newEmail?.rawValue else { return }
                    try await handleRequest(
                        for: makeRequest(.emailChange(.request(.init(newEmail: newEmail))))
                    )
                },
                confirm: { token in
                    try await handleRequest(
                        for: makeRequest(.emailChange(.confirm(.init(token: token))))
                    )
                }
            )
        )
    }
}

extension Identity.Consumer.Client {
    public enum Live {
        public struct Provider {
            public let baseURL: URL
            
            public init(baseURL: URL) {
                self.baseURL = baseURL
            }
        }
    }
}

extension Identity.Consumer.Client.Live {
    public static var makeRequest: (AnyParserPrinter<URLRequestData, Identity.API>)->(_ route: Identity.API) throws -> URLRequest {
        {
            apiRouter in
            { route in
                do {
                    let data = try apiRouter.print(route)
                    guard let request = URLRequest(data: data)
                    else { throw Identity.Consumer.Client.Error.requestError }
                    return request
                } catch {
                    throw Identity.Consumer.Client.Error.printError
                }
            }
        }
    }
}


extension Identity.Consumer.Client {
    public enum Error: Swift.Error {
        case requestError
        case printError
    }
}
