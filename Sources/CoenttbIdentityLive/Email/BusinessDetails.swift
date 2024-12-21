//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 10/10/2024.
//

import CoenttbIdentity
import EmailAddress
import Foundation
import CoenttbHTML
import Mailgun
import CoenttbWebTranslations
import MemberwiseInit

@MemberwiseInit(.public)
public struct BusinessDetails: Sendable {
    public let name: String
    public let supportEmail: String
    public let fromEmail: String
    public let primaryColor: HTMLColor
}
