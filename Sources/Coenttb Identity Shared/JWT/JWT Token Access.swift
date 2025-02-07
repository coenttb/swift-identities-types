import Dependencies
@preconcurrency import Fluent
import Foundation
@preconcurrency import Vapor
import JWT
import Vapor

extension JWT.Token {
    public struct Access: Codable, Sendable {
        // Required Standard JWT Claims
        public var expiration: ExpirationClaim
        public var issuedAt: IssuedAtClaim
        public var subject: SubjectClaim
        public var issuer: IssuerClaim
        public var audience: AudienceClaim
        
        // Optional Standard Claims
        public var notBefore: NotBeforeClaim?
        public var tokenId: IDClaim?
        
        // Required Custom Claims
        public var identityId: UUID
        public var email: String
        
        package init(
            expiration: ExpirationClaim,
            issuedAt: IssuedAtClaim,
            subject: SubjectClaim,
            issuer: IssuerClaim,
            audience: AudienceClaim,
            notBefore: NotBeforeClaim? = nil,
            tokenId: IDClaim? = nil,
            identityId: UUID,
            email: String
        ) {
            self.expiration = expiration
            self.issuedAt = issuedAt
            self.subject = subject
            self.issuer = issuer
            self.audience = audience
            self.notBefore = notBefore
            self.tokenId = tokenId
            self.identityId = identityId
            self.email = email
            
            self.audience.value.append("access")
        }
        
        enum CodingKeys: String, CodingKey {
            case expiration = "exp"
            case issuedAt = "iat"
            case subject = "sub"
            case issuer = "iss"
            case audience = "aud"
            case notBefore = "nbf"
            case tokenId = "jti"
            case identityId = "iid"
            case email = "eml"
        }
    }
}

extension JWT.Token.Access: JWTPayload {
    public func verify(using algorithm: some JWTKit.JWTAlgorithm) async throws {
        try self.expiration.verifyNotExpired()
        try self.notBefore?.verifyNotBefore()
        guard !self.email.isEmpty else {
            throw JWTError.claimVerificationFailure(
                failedClaim: self.expiration,
                reason: "email cannot be empty"
            )
        }
    }
}
