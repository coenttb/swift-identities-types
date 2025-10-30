//
//  Identity.MFA.BackupCodes.API.swift
//  swift-identities
//
//  Created by Coen ten Thije Boonkkamp on 19/08/2025.
//

import CasePaths
import Foundation
import TypesFoundation

extension Identity.MFA.BackupCodes {
  /// Backup code operations.
  @CasePathable
  @dynamicMemberLookup
  public enum API: Equatable, Sendable {
    /// Regenerate backup codes
    case regenerate

    /// Verify a backup code during authentication
    case verify(Identity.MFA.BackupCodes.Verify)

    /// Get count of remaining codes
    case remaining
  }
}

extension Identity.MFA.BackupCodes.API {
  /// Router for BackupCodes endpoints.
  public struct Router: ParserPrinter, Sendable {

    public init() {}

    public var body: some URLRouting.Router<Identity.MFA.BackupCodes.API> {
      OneOf {
        URLRouting.Route(.case(Identity.MFA.BackupCodes.API.regenerate)) {
          Method.post
          Path { "regenerate" }
        }

        URLRouting.Route(.case(Identity.MFA.BackupCodes.API.verify)) {
          Method.post
          Path.verify
          Body(.json(Identity.MFA.BackupCodes.Verify.self))
        }

        URLRouting.Route(.case(Identity.MFA.BackupCodes.API.remaining)) {
          Method.get
          Path { "remaining" }
        }
      }
    }
  }
}
