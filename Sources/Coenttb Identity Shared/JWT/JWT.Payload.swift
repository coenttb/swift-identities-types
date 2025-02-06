import Dependencies
@preconcurrency import Fluent
import Foundation
@preconcurrency import Vapor
import JWT

extension JWT {
    public struct Payload: Content, Authenticatable, JWTPayload {
        // Required Standard JWT Claims
        public var expiration: ExpirationClaim            // Expiration time
        public var issuedAt: IssuedAtClaim             // Issued at time
        public var subject: SubjectClaim              // Subject (user ID)
        public var issuer: IssuerClaim               // Issuer
        
        // Optional Standard JWT Claims
        public var notBefore: NotBeforeClaim?           // Not valid before
        public var audience: AudienceClaim?            // Audience
        public var tokenId: IDClaim?                  // JWT ID (unique identifier)
        
        // Required Custom Claims
        public var identityId: UUID               // Database ID reference
        public var email: String                  // User's email
        public var sessionVersion: Int            // Session version for revocation
        
        enum CodingKeys: String, CodingKey {
            case expiration = "exp"
            case issuedAt = "iat"
            case subject = "sub"
            case issuer = "iss"
            case notBefore = "nbf"
            case audience = "aud"
            case tokenId = "jti"
            case identityId = "iid"
            case email = "eml"
            case sessionVersion = "sev"
        }
        
        package init(
            expiration: ExpirationClaim,
            issuedAt: IssuedAtClaim,
            subject: SubjectClaim,
            issuer: IssuerClaim,
            notBefore: NotBeforeClaim? = nil,
            audience: AudienceClaim? = nil,
            tokenId: IDClaim? = nil,
            identityId: UUID,
            email: String,
            sessionVersion: Int
        ) {
            self.expiration = expiration
            self.issuedAt = issuedAt
            self.subject = subject
            self.issuer = issuer
            self.notBefore = notBefore
            self.audience = audience
            self.tokenId = tokenId
            self.identityId = identityId
            self.email = email
            self.sessionVersion = sessionVersion
        }
        
        public func verify(using algorithm: some JWTAlgorithm) throws {
            // Verify required claims
            try expiration.verifyNotExpired()
            
            // Verify optional claims if present
            try notBefore?.verifyNotBefore()
            
            // Additional custom verifications
            guard !email.isEmpty else {
                throw JWTError.claimVerificationFailure(
                    failedClaim: expiration,
                    reason: "email cannot be empty"
                )
            }
        }
    }
}

extension JWT.Payload {
    public struct Config {
        
        public static let defaultExpiration: TimeInterval = 60 * 15 // 15 minutes default
        
        public let issuer: String
        public let audience: String?
        public let expiration: TimeInterval
        
        public init(
            issuer: String,
            audience: String? = nil,
            expiration: TimeInterval = Self.defaultExpiration
        ) {
            self.issuer = issuer
            self.audience = audience
            self.expiration = expiration
        }
    }
}
import JWT
import Vapor

// Helpers to configure JWT middleware
extension Application {
    public func configureJWT() async throws {
        // Get keys from environment
        if let privateKeyString = Environment.get("JWT_PRIVATE_KEY") {
            let privateKey = try EdDSA.PrivateKey(
                d: privateKeyString,
                curve: .ed25519
            )
            await jwt.keys.add(eddsa: privateKey)
        }
        
        if let publicKeyString = Environment.get("JWT_PUBLIC_KEY") {
            let publicKey = try EdDSA.PublicKey(
                x: publicKeyString,
                curve: .ed25519
            )
            await jwt.keys.add(eddsa: publicKey)
        }
        
#if DEBUG
        if Environment.get("JWT_PRIVATE_KEY") == nil {
            // For development only - generate new key pair
            let key = try EdDSA.PrivateKey(curve: .ed25519)
            await jwt.keys.add(eddsa: key)
            
            // Print keys for development setup
            print("Development JWT Keys - DO NOT USE IN PRODUCTION")
            print("Private Key (d):", String(describing: key))
            print("Public Key (x):", String(describing: key))
        }
#endif
    }
}
