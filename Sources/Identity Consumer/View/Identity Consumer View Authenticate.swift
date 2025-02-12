//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 07/10/2024.
//

import Coenttb_Web
import CasePaths
import Identity_Shared

extension Identity.Consumer.View {
    @CasePathable
    public enum Authenticate: Codable, Hashable, Sendable {
        case credentials
        case multifactor(Identity.Consumer.View.Authenticate.Multifactor)
    }
}

