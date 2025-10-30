//
//  File 2.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 26/07/2025.
//

import Foundation
import URLFormCoding

extension URLFormCoding.Form.Decoder {
  public static var identities: URLFormCoding.Form.Decoder {
    URLFormCoding.Form.Decoder(arrayParsingStrategy: .bracketsWithIndices)
  }
}

extension URLFormCoding.Form.Encoder {
  public static var identities: URLFormCoding.Form.Encoder {
    URLFormCoding.Form.Encoder(arrayEncodingStrategy: .bracketsWithIndices)
  }
}
