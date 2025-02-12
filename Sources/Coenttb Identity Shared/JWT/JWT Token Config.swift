import Dependencies
import Foundation
import JWT
import Vapor

extension JWT.Token {
    public struct Config: Codable, Hashable, Sendable {
        public static let accessTokenLifetime: TimeInterval = 60 * 15     // 15 minutes
        public static let refreshTokenLifetime: TimeInterval = 60 * 60 * 24 * 7  // 7 days
        
        public let issuer: String
        public let expiration: TimeInterval
        
        private init(
            issuer: String,
            expiration: TimeInterval
        ) {
            self.issuer = issuer
            self.expiration = expiration
        }
    }
}

private enum AccessTokenConfig: DependencyKey {
    public static let liveValue: JWT.Token.Config = .forAccessToken(issuer: "default-issuer")
    public static let testValue: JWT.Token.Config = liveValue
}

extension DependencyValues {
    public var accessTokenConfig: JWT.Token.Config {
        get { self[AccessTokenConfig.self] }
        set { self[AccessTokenConfig.self] = newValue }
    }
}

private enum RefreshTokenConfig: DependencyKey {
    public static let liveValue: JWT.Token.Config = .forAccessToken(issuer: "default-issuer")
    public static let testValue: JWT.Token.Config = liveValue
}

extension DependencyValues {
    public var refreshTokenConfig: JWT.Token.Config {
        get { self[RefreshTokenConfig.self] }
        set { self[RefreshTokenConfig.self] = newValue }
    }
}

private enum ReauthorizationTokenConfig: DependencyKey {
    public static let liveValue: JWT.Token.Config = .forReauthorizationToken(issuer: "default-issuer")
    public static let testValue: JWT.Token.Config = liveValue
}

extension DependencyValues {
    public var reauthorizationTokenConfig: JWT.Token.Config {
        get { self[ReauthorizationTokenConfig.self] }
        set { self[ReauthorizationTokenConfig.self] = newValue }
    }
}


extension JWT.Token.Config {
    public static func forAccessToken(
        issuer: String,
        expiration: TimeInterval = Self.accessTokenLifetime
    ) -> Self {
        .init(
            issuer: issuer,
            expiration: expiration
        )
    }
    
    public static func forRefreshToken(
        issuer: String,
        expiration: TimeInterval = Self.refreshTokenLifetime
    ) -> Self {
        .init(
            issuer: issuer,
            expiration: expiration
        )
    }
    
    public static func forReauthorizationToken(
        issuer: String,
        expiration: TimeInterval = Self.refreshTokenLifetime
    ) -> Self {
        .init(
            issuer: issuer,
            expiration: expiration
        )
    }
}

