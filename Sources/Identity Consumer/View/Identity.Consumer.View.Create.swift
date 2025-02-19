//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 29/01/2025.
//

import CasePaths
import SwiftWeb
import Identity_Shared

extension Identity.Consumer.View {
    @CasePathable
    public enum Create: Codable, Hashable, Sendable {
        case request
        case verify(Identity.Create.Verify)
    }
}
