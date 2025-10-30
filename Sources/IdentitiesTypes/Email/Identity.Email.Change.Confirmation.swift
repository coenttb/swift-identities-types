//
//  File.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import TypesFoundation

extension Identity.Email.Change {
  /// Confirmation data for completing an email change.
  ///
  /// This type represents the final step in the email change flow where
  /// a user confirms their new email address using a verification token.
  public struct Confirmation: Codable, Hashable, Sendable {
    /// The verification token received via email.
    public let token: String

    /// Creates a new email change confirmation.
    ///
    /// - Parameter token: The verification token received via email.
    public init(
      token: String = ""
    ) {
      self.token = token
    }

    /// Keys for coding and decoding Confirmation instances.
    public enum CodingKeys: String, CodingKey {
      case token
    }
  }
}

extension Identity.Email.Change.Confirmation {
  /// Router for handling email change confirmation endpoints.
  ///
  /// Routes POST requests to the "/confirm" path with form-encoded body.
  public struct Router: ParserPrinter, Sendable {
    public init() {}

    public var body: some URLRouting.Router<Identity.Email.Change.Confirmation> {
      Method.post
      Path { "confirm" }
      Body(.form(Identity.Email.Change.Confirmation.self, decoder: .identities))
    }
  }
}

extension Identity.Email.Change.Confirmation {
  /// The response type for a successful email change confirmation.
  ///
  /// This typealias indicates that after confirming an email change,
  /// the user receives a new set of authentication credentials.
  public typealias Response = Identity.Authentication.Response
}
