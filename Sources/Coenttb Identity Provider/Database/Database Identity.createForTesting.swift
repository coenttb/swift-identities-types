//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 01/02/2025.
//

import Foundation
import Coenttb_Web
import Coenttb_Server
import Fluent
import Coenttb_Vapor
import Identity_Provider
import FluentKit

extension Database.Identity {
    #if DEBUG
    public static func createForTesting(
        email: EmailAddress,
        password: String,
        emailVerificationStatus: EmailVerificationStatus = .unverified,
        sessionVersion: Int = 0
    ) throws -> Database.Identity {
        try .init(
            email: email,
            password: password,
            emailVerificationStatus: emailVerificationStatus,
            sessionVersion: sessionVersion
        )
    }
    #endif
}
