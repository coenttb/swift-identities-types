//
//  File.swift
//  swift-identity
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import Foundation
import Identity_Shared

extension Identity.Consumer {
    public enum Route: Equatable, Sendable {
        case api(Identity.Consumer.API)
        case view(Identity.Consumer.View)
    }
}
