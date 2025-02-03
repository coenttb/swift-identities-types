//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Foundation
import URLRouting

public struct Identity<User: Codable & Hashable & Sendable /*& Identifiable, UserIDParser: ParserPrinter & Sendable*/> /*where User.ID: LosslessStringConvertible & Sendable, UserIDParser.Input == URLRequestData, UserIDParser.Output == User.ID, UserIDParser: _EmptyInitializable*/ {}
