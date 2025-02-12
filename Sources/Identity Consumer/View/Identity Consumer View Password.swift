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
    public enum Password: Codable, Hashable, Sendable {
        case reset(Identity.Consumer.View.Password.Reset)
        case change(Identity.Consumer.View.Password.Change)
    }
}

extension Identity.Consumer.View.Password {
    public enum Reset: Codable, Hashable, Sendable {
        case request
        case confirm(Identity.Password.Reset.Confirm)
    }
    
    public enum Change: Codable, Hashable, Sendable {
        case request
    }
}
