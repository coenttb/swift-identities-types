import Dependencies
@preconcurrency import Fluent
import Foundation
@preconcurrency import Vapor
import JWT
import Vapor


extension JWT.Token {
    public struct Payload: Codable {

        public let accessToken: JWT.Token.Access
        public let refreshToken: JWT.Token.Refresh
        
        public init(
            accessToken: JWT.Token.Access,
            refreshToken: JWT.Token.Refresh
        ) throws {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
        }
    }
}

extension JWT.Token.Payload: JWTPayload {
    public func verify(using algorithm: some JWTKit.JWTAlgorithm) async throws {
        // Verify access token
        try await verifyAccessToken()
        
        // Verify refresh token
        try await verifyRefreshToken()
    }
    
    private func verifyAccessToken() async throws {
        // Verify expiration and timing
        try accessToken.expiration.verifyNotExpired()
        try accessToken.notBefore?.verifyNotBefore()
        
        // Verify required fields
        try verifyRequiredFields()
    }
    
    private func verifyRefreshToken() async throws {
        // Verify expiration and timing
        try refreshToken.expiration.verifyNotExpired()
        try refreshToken.notBefore?.verifyNotBefore()

        
        // Verify required fields
        try verifyRequiredFields()
    }
    
    private func verifyRequiredFields() throws {
        // Verify email is present
        guard !accessToken.email.isEmpty else {
            throw JWTError.claimVerificationFailure(
                failedClaim: accessToken.expiration,
                reason: "email cannot be empty"
            )
        }
        
        // Verify identityId matches between tokens
        guard accessToken.identityId == refreshToken.identityId else {
            throw JWTError.claimVerificationFailure(
                failedClaim: nil,
                reason: "identity mismatch between tokens"
            )
        }
        
        
    }
}


extension JWT.Token {
    public enum TokenType: String {
        case access = "access"
        case refresh = "refresh"
    }
    
    public struct PayloadConfig {
        // Token lifetimes
        public static let accessTokenLifetime: TimeInterval = 60 * 15     // 15 minutes
        public static let refreshTokenLifetime: TimeInterval = 60 * 60 * 24 * 7  // 7 days
        
        public let issuer: String
        public let tokenType: TokenType
        public let expiration: TimeInterval
        
        public init(
            issuer: String,
            tokenType: TokenType,
            expiration: TimeInterval
        ) {
            self.issuer = issuer
            self.tokenType = tokenType
            self.expiration = expiration
        }
        
        public static func forAccessToken(
            issuer: String,
            expiration: TimeInterval = accessTokenLifetime
        ) -> Self {
            .init(
                issuer: issuer,
                tokenType: .access,
                expiration: expiration
            )
        }
        
        public static func forRefreshToken(
            issuer: String,
            expiration: TimeInterval = refreshTokenLifetime
        ) -> Self {
            .init(
                issuer: issuer,
                tokenType: .refresh,
                expiration: expiration
            )
        }
    }
}

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
            let key = try EdDSA.PrivateKey(curve: .ed25519)
            await jwt.keys.add(eddsa: key)
            
            print("Development JWT Keys - DO NOT USE IN PRODUCTION")
            print("Private Key (d):", String(describing: key))
            print("Public Key (x):", String(describing: key))
        }
#endif
    }
}
