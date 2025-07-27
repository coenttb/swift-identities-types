//
//  File.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 26/07/2025.
//

import Foundation
import URLFormCoding

extension URLFormCoding.Form.Decoder {
    public static var identities: URLFormCoding.Form.Decoder {
        let decoder = URLFormCoding.Form.Decoder()
        decoder.parsingStrategy = .bracketsWithIndices
        return decoder
    }
}
