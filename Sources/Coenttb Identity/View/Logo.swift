//
//  File.swift
//  coenttb-web
//
//  Created by Coen ten Thije Boonkkamp on 20/09/2024.
//

import Foundation
import Coenttb_Web

public struct Logo: HTML {
    let logo: SVG
    let logoHref: URL
    
    public init(logo: SVG, logoHref: URL) {
        self.logo = logo
        self.logoHref = logoHref
    }
    
    public var body: some HTML {
        VStack {
            Link(href: logoHref.absoluteString) {
                logo
            }
            .linkColor(.primary)
            .display(.inlineBlock)
            .margin(horizontal: .auto)
        }
    }
}

