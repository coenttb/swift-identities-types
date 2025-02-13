import Coenttb_Identity_Shared
import Coenttb_Vapor
import Coenttb_Web
import Dependencies
import EmailAddress
import Identity_Consumer
import Identity_Shared
import JWT
import RateLimiter

extension Identity.Consumer.Client {
    public static func live(
        provider: Identity.Consumer.Client.Live.Provider,
        router: AnyParserPrinter<URLRequestData, Identity.Consumer.API>,
        makeRequest: @escaping (AnyParserPrinter<URLRequestData, Identity.Consumer.API>) -> (_ route: Identity.Consumer.API) throws -> URLRequest = Identity.Consumer.Client.Live.makeRequest
    ) -> Self {

        @Dependency(RateLimiters.self) var rateLimiter
        @Dependency(URLRequest.Handler.self) var handleRequest

        return .init(
            authenticate: .live(
                provider: provider,
                router: router,
                makeRequest: makeRequest
            ),
            logout: {
                @Dependency(\.request) var request
                guard let request else { throw Abort.requestUnavailable }
                request.auth.logout(JWT.Token.Access.self)
            },
            reauthorize: { password in
                @Dependency(\.request) var request
                guard let request else { throw Abort.requestUnavailable }

                let apiRouter = router
                    .setAccessToken(request.cookies.accessToken)
                    .setBearerAuth(request.cookies.accessToken?.string)
                    .baseURL(provider.baseURL.absoluteString)
                    .eraseToAnyParserPrinter()

                return try await handleRequest(
                    for: makeRequest(apiRouter)(.reauthorize(.init(password: password))),
                    decodingTo: JWT.Token.self
                )

            },
            create: .live(
                provider: provider,
                router: router,
                makeRequest: makeRequest
            ),
            delete: .live(
                provider: provider,
                router: router,
                makeRequest: makeRequest
            ),
            emailChange: .live(
                provider: provider,
                router: router,
                makeRequest: makeRequest
            ),
            password: .live(
                provider: provider,
                router: router,
                makeRequest: makeRequest
            )
        )
    }
}

extension Identity.Consumer.Client {
    public enum Live {
        public struct Provider {
            public let baseURL: URL
            public let domain: String?

            public init(baseURL: URL, domain: String?) {
                self.baseURL = baseURL
                self.domain = domain
            }
        }
    }
}

extension Identity.Consumer.Client.Live {
    public static var makeRequest: (AnyParserPrinter<URLRequestData, Identity.Consumer.API>) -> (_ route: Identity.Consumer.API) throws -> URLRequest {
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

extension URLRequest {
    /// Sets or removes the Authorization header with a Bearer token
    /// - Parameter token: The bearer token to be used for authentication. If nil, removes the Authorization header
    /// - Returns: A new URLRequest instance with the Authorization header set or removed
    public mutating func setBearerToken(_ token: String?) {
        if let token {
            setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }

    /// Sets the refresh token as a cookie
    /// - Parameter token: The refresh token to be set as a cookie. If nil, removes the refresh_token cookie
    public mutating func setRefreshTokenCookie(_ token: String?) {
        if let token = token {
            setValue("refresh_token=\(token)", forHTTPHeaderField: "Cookie")
        } else {
            setValue(nil, forHTTPHeaderField: "Cookie")
        }
    }
}

extension ParserPrinter where Input == URLRequestData {
    @inlinable
    public func cookie(_ name: String, _ value: HTTPCookies.Value) -> BaseURLPrinter<Self> {
        var requestData = URLRequestData()
        requestData.headers["cookie", default: []].append("\(name)=\(value.string)"[...])
        return self.baseRequestData(requestData)
    }

    @inlinable
     public func cookie(_ name: String, _ value: HTTPCookies.Value?) -> BaseURLPrinter<Self> {
       guard let value = value else { return self.baseRequestData(.init()) }
       return self.cookie(name, value)
     }

    @inlinable
    public func setAccessToken(_ token: HTTPCookies.Value?) -> BaseURLPrinter<Self> {
        return self.cookie("access_token", token)
    }

    @inlinable
    public func setRefreshToken(_ token: HTTPCookies.Value?) -> BaseURLPrinter<Self> {
        return self.cookie("refresh_token", token)
    }

    @inlinable
    public func setReauthorizationToken(_ token: HTTPCookies.Value?) -> BaseURLPrinter<Self> {
        return self.cookie("reauthorization_token", token)
    }

    @inlinable
    public func cookies(_ cookies: [String: HTTPCookies.Value]) -> BaseURLPrinter<Self> {
        var requestData = URLRequestData()
        requestData.headers["cookie", default: []].append(
            cookies
                .map { name, value in "\(name)=\(value.string)" }
                .joined(separator: "; ")[...]
        )
        return self.baseRequestData(requestData)
    }
}

extension ParserPrinter where Input == URLRequestData {
    @inlinable
    public func transform(_ transform: @escaping (inout URLRequestData) -> URLRequestData) -> BaseURLPrinter<Self> {
        var requestData = URLRequestData()
        requestData = transform(&requestData)
        return self.baseRequestData(requestData)
    }
}

extension ParserPrinter where Input == URLRequestData {
    @inlinable
    public func setBearerAuth(_ token: String?) -> BaseURLPrinter<Self> {
        transform { urlRequestData in
            if let token = token {
                var data = urlRequestData
                data.headers["Authorization"] = ["Bearer \(token)"][...].map { Substring($0) }[...]
                return data
            }
            return urlRequestData
        }
    }
}

//
// extension ParserPrinter where Input == URLRequestData {
//    @inlinable
//    public static func setAccessToken(_ token: String?) -> BaseURLPrinter<Self> {
//        self.cookie("access_token", token)
//    }
//    
//    @inlinable
//    public static func setAccessToken(_ token: HTTPCookies.Value?) -> BaseURLPrinter<Self> {
//        self.cookie("access_token", token)
//    }
//    
//    @inlinable
//    public static func setRefreshToken(_ token: String?) -> BaseURLPrinter<Self> {
//        self.cookie("refresh_token", token)
//    }
//    
//    @inlinable
//    public static func setRefreshToken(_ token: HTTPCookies?) -> BaseURLPrinter<Self> {
//        self.cookie("refresh_token", token)
//    }
// }
