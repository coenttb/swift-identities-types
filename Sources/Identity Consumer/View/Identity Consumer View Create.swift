//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 29/01/2025.
//

import Coenttb_Web
import CasePaths
import Identity_Shared

extension Identity.Consumer.View {
    public enum Create: Codable, Hashable, Sendable {
        case request
        case verify(Identity.Create.Verify)
    }
}
