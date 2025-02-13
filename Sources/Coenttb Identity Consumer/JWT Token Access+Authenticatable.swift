//
//  File 2.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import Coenttb_Identity_Shared
import Foundation
import Vapor

extension JWT.Token.Access: Authenticatable {}

extension JWT.Token.Access: SessionAuthenticatable {
    public var sessionID: String {
        self.tokenId!.value.description
    }

}
