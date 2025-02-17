//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 13/02/2025.
//

import Foundation
import Coenttb_Web

extension Identity.Consumer.Client {
    @_disfavoredOverload
    public func handleRequest<ResponseType: Decodable>(
        for route: Identity.Consumer.API,
        decodingTo type: ResponseType.Type,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) async throws -> ResponseType {

        @Dependency(URLRequest.Handler.self) var handler
        
        let request = try self.makeRequest(route)
        
        return try await handler(
            for: request,
            decodingTo: type,
            fileID: fileID,
            filePath: filePath,
            line: line,
            column: column
        )
    }
}

extension Identity.Consumer.Client {
    public func handleRequest(
        for route: Identity.Consumer.API,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) async throws {
        let request = try makeRequest(route)
        
        @Dependency(URLRequest.Handler.self) var handler
        
        try await handler(for: request)
    }
}

extension Identity.Consumer.Client {
    package func makeRequest(_ route: Identity.Consumer.API) throws -> URLRequest {
        try Identity.Consumer.Client.makeRequest(route)
    }
}

extension Identity.Consumer.Client {
    package static func makeRequest(_ route: Identity.Consumer.API) throws -> URLRequest {
        
        @Dependency(\.identityProviderRouter) var router
        
        do {
            guard let request = try URLRequest(
                data: router
                    .configureAuthentication(for: route)
                    .print(route)
            )
            else { throw Identity.Consumer.Client.Error.requestError }
            
            return request
        } catch {
            throw Identity.Consumer.Client.Error.printError
        }
    }
}
