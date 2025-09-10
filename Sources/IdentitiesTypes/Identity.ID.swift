//
//  File.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 30/08/2025.
//

import ServerFoundation
import Foundation

extension Identity {
    public typealias ID = Tagged<Identity, UUID>
}
