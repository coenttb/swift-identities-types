import Dependencies
import EmailAddress
import Foundation
import JWT
import SwiftWeb
import Vapor

extension JWT.Token {
    public struct Refresh: Codable, Sendable {
        public var expiration: ExpirationClaim
        public var issuedAt: IssuedAtClaim
        public var subject: SubjectClaim
        public var tokenId: IDClaim

        public var sessionVersion: Int

        public var identityId: UUID {
            get {
                UUID(uuidString: subject.value)!
            }
            set {
                subject.value = "\(newValue.uuidString)"
            }
        }

        package init(
            expiration: ExpirationClaim,
            issuedAt: IssuedAtClaim,
            identityId: UUID,
            tokenId: IDClaim,
            sessionVersion: Int
        ) {
            self.expiration = expiration
            self.issuedAt = issuedAt
            self.subject = SubjectClaim(value: "\(identityId.uuidString)")
            self.tokenId = tokenId
            self.sessionVersion = sessionVersion
        }

        enum CodingKeys: String, CodingKey {
            case expiration = "exp"
            case issuedAt = "iat"
            case subject = "sub"
            case tokenId = "jti"
            case sessionVersion = "sev"
        }
    }
}

extension JWT.Token.Refresh: JWTPayload {
    public func verify(using algorithm: some JWTKit.JWTAlgorithm) async throws {
        @Dependency(\.date) var date
        try self.expiration.verifyNotExpired(currentDate: date())
    }
}
