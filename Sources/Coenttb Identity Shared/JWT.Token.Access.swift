import Dependencies
import EmailAddress
import Foundation
import JWT
import Vapor
import SwiftWeb

extension JWT.Token {
    public struct Access: Codable, Sendable {
        // Required Standard JWT Claims
        public var expiration: ExpirationClaim
        public var issuedAt: IssuedAtClaim
        public var subject: SubjectClaim
        public var notBefore: NotBeforeClaim?
        
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
                subject.value = "\(id):\(newValue.rawValue)"
            }
        }
        
        package init(
            expiration: ExpirationClaim,
            issuedAt: IssuedAtClaim,
            identityId: UUID,
            email: EmailAddress,
            notBefore: NotBeforeClaim? = nil
        ) {
            self.expiration = expiration
            self.issuedAt = issuedAt
            self.subject = SubjectClaim(value: "\(identityId.uuidString):\(email.rawValue)")
            self.notBefore = notBefore
        }
        
        enum CodingKeys: String, CodingKey {
            case expiration = "exp"
            case issuedAt = "iat"
            case subject = "sub"
            case notBefore = "nbf"
        }
    }
}

extension JWT.Token.Access: JWTPayload {
    public func verify(using algorithm: some JWTKit.JWTAlgorithm) async throws {
        try self.expiration.verifyNotExpired()
    }
}
