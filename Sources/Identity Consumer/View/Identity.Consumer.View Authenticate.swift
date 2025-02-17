//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 07/10/2024.
//

import CasePaths
import Coenttb_Web
import Identity_Shared

extension Identity.Consumer.View {
    @CasePathable
    public enum Authenticate: Codable, Hashable, Sendable {
        case credentials
    }
}
