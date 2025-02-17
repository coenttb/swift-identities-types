//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 01/02/2025.
//

import Coenttb_Server
import Coenttb_Vapor
import Coenttb_Web
import Fluent
import FluentKit
import Foundation
import Identity_Provider

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
