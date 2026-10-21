import HTTP
import HTTP_Router
import IdentitiesTypes
import RFC_3986
import RFC_6750
import RFC_9110
import Testing

@Suite
struct `Identity API key method` {

    static func request(_ method: HTTP.Method) throws -> HTTP.Router.Request {
        var request = HTTP.Router.Request(
            method: method,
            target: .resource(RFC_3986.URI(unchecked: "/api-key"))
        )
        request.headers.append(
            try RFC_9110.Field(name: "Authorization", value: "Bearer parity-token-123")
        )
        return request
    }

    @Test
    func `the API key route matches and emits POST with the bearer`() throws {
        let bearer = try RFC_6750.Bearer(token: "parity-token-123")
        let emitted = try HTTP.request(Identity.Authentication.API.self, for: .apiKey(bearer))
        #expect(emitted.method == .post)
        #expect(emitted.headers[.authorization].map(\.rawValue) == ["Bearer parity-token-123"])
        #expect(try HTTP.route(Identity.Authentication.API.self, emitted) == .apiKey(bearer))
        #expect(
            try HTTP.route(Identity.Authentication.API.self, Self.request(.post)) == .apiKey(bearer)
        )
    }

    @Test
    func `the API key route does not match other methods`() throws {
        for method in [HTTP.Method.get, .put, .delete] {
            #expect(throws: HTTP.Router.Error.self) {
                try HTTP.route(Identity.Authentication.API.self, Self.request(method))
            }
        }
    }
}

@Suite
struct `Identity route method classes` {

    static func request(_ method: HTTP.Method, _ target: String) -> HTTP.Router.Request {
        HTTP.Router.Request(method: method, target: .resource(RFC_3986.URI(unchecked: target)))
    }

    @Test
    func `view pages match GET and emit GET`() throws {
        #expect(
            try HTTP.route(Identity.View.self, Self.request(.get, "/login"))
                == .authenticate(.credentials)
        )
        #expect(
            try HTTP.request(Identity.View.self, for: .authenticate(.credentials)).method == .get
        )
        #expect(
            try HTTP.route(Identity.View.self, Self.request(.get, "/mfa/manage")) == .mfa(.manage)
        )
    }

    @Test
    func `view pages do not match non-GET methods`() {
        for method in [HTTP.Method.post, .put, .delete] {
            #expect(throws: HTTP.Router.Error.self) {
                try HTTP.route(Identity.View.self, Self.request(method, "/login"))
            }
            #expect(throws: HTTP.Router.Error.self) {
                try HTTP.route(Identity.View.self, Self.request(method, "/password/reset/request"))
            }
        }
    }

    @Test
    func `explicit API methods keep their method`() {
        #expect(throws: HTTP.Router.Error.self) {
            try HTTP.route(Identity.API.self, Self.request(.get, "/authenticate"))
        }
    }
}

@Suite
struct `Identity logout method` {

    static func request(_ method: HTTP.Method, _ target: String) -> HTTP.Router.Request {
        HTTP.Router.Request(method: method, target: .resource(RFC_3986.URI(unchecked: target)))
    }

    @Test
    func `the logout view action matches and emits POST /logout/view`() throws {
        let emitted = try HTTP.request(Identity.View.self, for: .logout)
        #expect(emitted.method == .post)
        #expect(emitted.target == Self.request(.post, "/logout/view").target)
        #expect(try HTTP.route(Identity.View.self, emitted) == .logout)
        let feature = try HTTP.request(Identity.Logout.Route.self, for: .view)
        #expect(feature.method == .post)
        #expect(feature.target == Self.request(.post, "/logout/view").target)
    }

    @Test
    func `the logout view action rejects GET, HEAD and other non-POST methods`() {
        for method in [HTTP.Method.get, .head, .put, .delete] {
            #expect(throws: HTTP.Router.Error.self) {
                try HTTP.route(Identity.View.self, Self.request(method, "/logout/view"))
            }
            #expect(throws: HTTP.Router.Error.self) {
                try HTTP.route(Identity.Logout.Route.self, Self.request(method, "/logout/view"))
            }
        }
    }

    @Test
    func `API and view logout round-trip distinctly`() throws {
        for route: Identity.Logout.Route in [.view, .api(.current), .api(.all)] {
            #expect(
                try HTTP.route(
                    Identity.Logout.Route.self,
                    HTTP.request(Identity.Logout.Route.self, for: route)
                ) == route
            )
        }
        #expect(
            try HTTP.route(Identity.Logout.Route.self, Self.request(.post, "/logout"))
                == .api(.current)
        )
        #expect(
            try HTTP.route(Identity.Logout.Route.self, Self.request(.post, "/logout/all"))
                == .api(.all)
        )
        #expect(
            try HTTP.route(Identity.Logout.Route.self, Self.request(.post, "/logout/view")) == .view
        )
    }

    @Test
    func `the old view URL no longer reaches the view action`() {
        #expect(throws: HTTP.Router.Error.self) {
            try HTTP.route(Identity.View.self, Self.request(.post, "/logout"))
        }
    }
}
