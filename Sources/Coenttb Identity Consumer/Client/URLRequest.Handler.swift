//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 13/02/2025.
//

import Foundation
import Coenttb_Web

extension URLRequest.Handler {
    public func callAsFunction<ResponseType: Decodable>(
        baseRouter: AnyParserPrinter<URLRequestData, Identity.Consumer.API>,
        route: Identity.Consumer.API,
        makeRequest: @escaping (AnyParserPrinter<URLRequestData, Identity.Consumer.API>) -> (_ route: Identity.Consumer.API) throws -> URLRequest = Identity.Consumer.Client.makeRequest,
        decodingTo type: ResponseType.Type,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) async throws -> ResponseType {
        let router = try Identity.Consumer.API.Router.prepare(
            baseRouter: baseRouter,
            route: route
        )
        let request = try makeRequest(router)(route)
        
        return try await callAsFunction(
            for: request,
            decodingTo: type,
            fileID: fileID,
            filePath: filePath,
            line: line,
            column: column
        )
    }
}

extension URLRequest.Handler {
    public func callAsFunction(
        baseRouter: AnyParserPrinter<URLRequestData, Identity.Consumer.API>,
        route: Identity.Consumer.API,
        makeRequest: @escaping (AnyParserPrinter<URLRequestData, Identity.Consumer.API>) -> (_ route: Identity.Consumer.API) throws -> URLRequest = Identity.Consumer.Client.makeRequest,
        fileID: StaticString = #fileID,
        filePath: StaticString = #filePath,
        line: UInt = #line,
        column: UInt = #column
    ) async throws {
        let router = try Identity.Consumer.API.Router.prepare(
            baseRouter: baseRouter,
            route: route
        )
        let request = try makeRequest(router)(route)
        
        try await callAsFunction(for: request)
    }
}
