//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 10/10/2024.
//

import Coenttb_Identity
import Mailgun
import Coenttb_Web

public struct BusinessDetails: Sendable {
    public let name: String
    public let supportEmail: EmailAddress
    public let fromEmail: EmailAddress
    public let primaryColor: HTMLColor
    
    public init(name: String, supportEmail: EmailAddress, fromEmail: EmailAddress, primaryColor: HTMLColor) {
        self.name = name
        self.supportEmail = supportEmail
        self.fromEmail = fromEmail
        self.primaryColor = primaryColor
    }
}
