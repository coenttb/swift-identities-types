//
//  Identity.MFA.WebAuthn.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import TypesFoundation

extension Identity.MFA {
  /// WebAuthn-specific types and operations.
  public struct WebAuthn: @unchecked Sendable {
    public var client: Identity.MFA.WebAuthn.Client
    public var router: any URLRouting.Router<Identity.MFA.WebAuthn.API>

    public init(
      client: Identity.MFA.WebAuthn.Client,
      router: any URLRouting.Router<Identity.MFA.WebAuthn.API> = Identity.MFA.WebAuthn.API.Router()
    ) {
      self.client = client
      self.router = router
    }
  }
}

extension Identity.MFA.WebAuthn {
  /// Response from beginning WebAuthn registration.
  public struct BeginRegistrationResponse: Codable, Equatable, Sendable {
    public let challenge: String
    public let options: String  // JSON encoded PublicKeyCredentialCreationOptions

    public init(challenge: String, options: String) {
      self.challenge = challenge
      self.options = options
    }
  }

  /// Request to finish WebAuthn registration.
  public struct FinishRegistration: Codable, Equatable, Sendable {
    public let credentialName: String
    public let response: String  // JSON encoded credential response

    public init(credentialName: String, response: String) {
      self.credentialName = credentialName
      self.response = response
    }
  }

  /// Response from beginning WebAuthn authentication.
  public struct BeginAuthenticationResponse: Codable, Equatable, Sendable {
    public let challenge: String
    public let options: String  // JSON encoded PublicKeyCredentialRequestOptions

    public init(challenge: String, options: String) {
      self.challenge = challenge
      self.options = options
    }
  }

  /// Request to finish WebAuthn authentication.
  public struct FinishAuthentication: Codable, Equatable, Sendable {
    public let response: String  // JSON encoded credential response
    public let sessionToken: String

    public init(response: String, sessionToken: String) {
      self.response = response
      self.sessionToken = sessionToken
    }
  }

  /// Registered WebAuthn credential.
  public struct Credential: Codable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let createdAt: Date
    public let lastUsedAt: Date?

    public init(id: String, name: String, createdAt: Date, lastUsedAt: Date? = nil) {
      self.id = id
      self.name = name
      self.createdAt = createdAt
      self.lastUsedAt = lastUsedAt
    }
  }

  /// Request to remove a credential.
  public struct RemoveCredential: Codable, Equatable, Sendable {
    public let credentialId: String
    public let reauthorizationToken: String

    public init(credentialId: String, reauthorizationToken: String) {
      self.credentialId = credentialId
      self.reauthorizationToken = reauthorizationToken
    }
  }
}
