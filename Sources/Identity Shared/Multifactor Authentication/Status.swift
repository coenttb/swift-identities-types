//
//  MultifactorAuthentication.Status.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 31/01/2025.
//

import Foundation

extension MultifactorAuthentication {
    public enum Status: String, Codable, Hashable, Sendable {
        case disabled = "Disabled"
        case enabled = "Enabled"
        case pending = "Pending"
    }
}
