//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 28/02/2025.
//

import Foundation
import VaporTesting
import Coenttb_Identity_Provider
import Dependencies
import URLRouting
import VaporTesting
import JWT
import Vapor
import Fluent

func withTestApp(_ test: (Application) async throws -> ()) async throws {
    // Create a unique database ID for this test run to prevent cross-test contamination
    let dbId = UUID().uuidString
    let testId = dbId.prefix(8)
    print("🔵 Test starting with ID: \(testId)")
    
    let app = try await Application.make(.testing)
    
    // Use a unique database ID for isolation between tests
    let db = DatabaseID(string: dbId)
    app.databases.use(.sqlite(.memory), as: db)
    app.migrations.add(Database.Migration())
    app.middleware.use(Identity.Provider.Middleware())
    
    try await app.autoMigrate()
    
    try await withDependencies {
        $0.application = app
        $0.database = app.databases.database(db, logger: $0.logger, on: app.eventLoopGroup.next())!
    } operation: {
        @Dependency(\.application) var application
        
        do {
            let key = ES256PrivateKey()
            await application.jwt.keys.add(ecdsa: key)
            try await application.autoMigrate()
            
            @Dependency(\.identity.provider.router) var router
            
            application.mount(router, use: Identity.Provider.API.response)
            
            print("🔵 Running test with ID: \(testId)")
            try await test(app)
            print("🔵 Test completed: \(testId)")
            
            try await application.autoRevert()
        }
        catch {
            print("🔴 Test failed: \(testId) - Error: \(error)")
            try await application.asyncShutdown()
            throw error
        }
        
        print("🔵 Test cleanup: \(testId)")
        try await app.asyncShutdown()
    }
}

extension TestingHTTPRequest {
    init(
        _ route: Identity.API
    ) throws {
        @Dependency(\.identity.provider.router) var router
        
        let urlRequestData = try router.print(route)
        try self.init(urlRequestData)
    }
}

extension TestingHTTPRequest {
    init(_ urlRequestData: URLRequestData) throws {
        // Create HTTP method from URLRequestData method
        guard let methodString = urlRequestData.method else {
            throw URLError(.badURL, userInfo: ["reason": "Missing HTTP method"])
        }
        let method = HTTPMethod(rawValue: methodString)
        
        // Construct URI from URLRequestData components
        var url = URI()
        
        // Set scheme
        if let scheme = urlRequestData.scheme {
            url.scheme = scheme
        }
        
        // Set host
        if let host = urlRequestData.host {
            url.host = host
        }
        
        // Set port
        if let port = urlRequestData.port {
            url.port = port
        }
        
        // Set path
        url.path = "/" + urlRequestData.path.joined(separator: "/")
        
        // Set query parameters
        if !urlRequestData.query.fields.isEmpty {
            var queryItems: [String: String] = [:]
            for (name, values) in urlRequestData.query.fields {
                // Use first value for simplicity
                if let firstValue = values.first, let unwrappedValue = firstValue {
                    queryItems[name] = String(unwrappedValue)
                }
            }
            url.query = queryItems.map { "\($0)=\($1)" }.joined(separator: "&")
        }
        
        // Set fragment
        if let fragment = urlRequestData.fragment {
            url.fragment = fragment
        }
        
        // Create headers
        var headers = HTTPHeaders()
        for (name, values) in urlRequestData.headers.fields {
            for value in values {
                if let value {
                    headers.add(name: name, value: String(value))
                }
            }
        }
        
        var body: ByteBuffer {
            urlRequestData.body.flatMap{ data in ByteBuffer.init(data: data) }
            ?? {
                let allocator = ByteBufferAllocator()
                return allocator.buffer(capacity: 0)
            }()
        }
        
        self.init(method: method, url: url, headers: headers, body: body)
    }
}

// Helper extension to provide context-specific error
extension URLError {
    static func badURL(reason: String) -> URLError {
        return URLError(.badURL, userInfo: ["reason": reason])
    }
}

extension Application {
    func test(identity route: Identity.API) async throws -> TestingHTTPResponse {
        try await self.testing().performTest(request: .init(route))
    }
}

extension Identity.Provider.Client {
    static let liveTest: Self = .live(
        sendVerificationEmail: { email, token in
            print("sendVerificationEmail called")
        },
        sendPasswordResetEmail: { email, token in
            print("sendPasswordResetEmail called")
        },
        sendPasswordChangeNotification: { email in
            print("sendPasswordChangeNotification called")
        },
        sendEmailChangeConfirmation: { currentEmail, newEmail, token in
            print("sendEmailChangeConfirmation called")
        },
        sendEmailChangeRequestNotification: { currentEmail, newEmail in
            print("sendEmailChangeRequestNotification called")
        },
        onEmailChangeSuccess: { currentEmail, newEmail in
            print("onEmailChangeSuccess called")
        },
        sendDeletionRequestNotification: { email in
            print("sendDeletionRequestNotification called")
        },
        sendDeletionConfirmationNotification: { email in
            print("sendDeletionConfirmationNotification called")
        }
    )
}
