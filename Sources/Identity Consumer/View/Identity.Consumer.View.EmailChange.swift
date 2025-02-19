//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 29/01/2025.
//

import CasePaths
import Coenttb_Web
import Identity_Shared

extension Identity.Consumer.View {
    @CasePathable
    public enum Email: Codable, Hashable, Sendable {
        case change(Identity.Consumer.View.Email.Change)
    }
}

extension Identity.Consumer.View.Email {
    public enum Change: Codable, Hashable, Sendable {
        case request
        case confirm(Identity.Email.Change.Confirm)
        case reauthorization
    }
}
