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
    public enum EmailChange: Codable, Hashable, Sendable {
        case request
        case confirm(Identity.EmailChange.Confirm)
        case reauthorization
    }
}
