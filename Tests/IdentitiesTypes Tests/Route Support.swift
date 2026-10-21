import Byte
import HTTP
import HTTP_Router
import IdentitiesTypes
import RFC_3986
import RFC_9110

extension HTTP.Routable where Router.Output == Self {
    static func request(for route: Self) throws -> HTTP.Router.Request {
        try HTTP.request(Self.self, for: route)
    }

    static func match(request: HTTP.Router.Request) throws -> Self {
        try HTTP.route(Self.self, request)
    }
}

extension RFC_9110.Message.Request where Content == [Byte] {
    var path: String? {
        guard case .resource(let uri) = target else { return nil }
        return uri.path?.description
    }
}

enum RouteRequest {
    static func make(
        _ method: HTTP.Method = .get,
        path: String,
        query: [(String, String)] = []
    ) -> HTTP.Router.Request {
        let encoded = query.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
        return HTTP.Router.Request(
            method: method,
            target: .resource(
                RFC_3986.URI(unchecked: encoded.isEmpty ? path : "\(path)?\(encoded)")
            )
        )
    }
}

extension RFC_9110.Message.Request where Content == [Byte] {
    var pathComponents: [String] {
        guard case .resource(let uri) = target, let path = uri.path else { return [] }
        return path.segments.map {
            String(decoding: RFC_3986.percentDecode(Array($0.utf8)), as: UTF8.self)
        }
    }

    var queryItems: [String: [String]] {
        guard case .resource(let uri) = target, let query = uri.query else { return [:] }
        var items: [String: [String]] = [:]
        for parameter in query.parameters {
            let key = String(
                decoding: RFC_3986.percentDecode(Array(parameter.key.utf8)),
                as: UTF8.self
            )
            let value =
                parameter.value.map {
                    String(decoding: RFC_3986.percentDecode(Array($0.utf8)), as: UTF8.self)
                } ?? ""
            items[key, default: []].append(value)
        }
        return items
    }
}
