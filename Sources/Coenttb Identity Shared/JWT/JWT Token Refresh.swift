import Dependencies
import Foundation
import JWT
import Vapor
import EmailAddress

extension JWT.Token {
    public struct Refresh: Codable, Sendable {
        public var expiration: ExpirationClaim
        public var issuedAt: IssuedAtClaim
        public var subject: SubjectClaim
        public var tokenId: IDClaim
        
        public var sessionVersion: Int
        
        public var identityId: UUID {
            get {
                UUID(uuidString: subject.value.components(separatedBy: ":")[0])!
            }
            set {
                let email = subject.value.components(separatedBy: ":")[1]
                subject.value = "\(newValue.uuidString):\(email)"
            }
        }
        
        public var email: EmailAddress {
            get {
                EmailAddress(rawValue: subject.value.components(separatedBy: ":")[1])!
            }
            set {
                let id = subject.value.components(separatedBy: ":")[0]
                subject.value = "\(id):\(newValue)"
            }
        }
        
        package init(
            expiration: ExpirationClaim,
            issuedAt: IssuedAtClaim,
            identityId: UUID,
            email: EmailAddress,
            tokenId: IDClaim,
            sessionVersion: Int
        ) {
            self.expiration = expiration
            self.issuedAt = issuedAt
            self.subject = SubjectClaim(value: "\(identityId.uuidString):\(email)")
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
        try self.expiration.verifyNotExpired()
    }
}
