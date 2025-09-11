//
//  File.swift
//  swift-identities-types
//
//  Created by Coen ten Thije Boonkkamp on 11/09/2025.
//

import Authenticating
import TypesFoundation
import DependenciesMacros
import JWT

extension Identity.Authentication {
    /// Types of authentication tokens supported by the system.
    ///
    /// The system uses a dual-token approach:
    /// - Access tokens for API authentication
    /// - Refresh tokens for obtaining new access tokens
    ///
    /// This approach enhances security by limiting access token lifetimes
    /// while maintaining session persistence through refresh tokens.
    public enum Token: Equatable, Sendable {
        /// Short-lived token for API authentication
        case access(BearerAuth)
        /// Long-lived token for obtaining new access tokens
        case refresh(JWT)
    }
}

extension Identity.Authentication {
    /// Response containing authentication tokens after successful authentication.
    ///
    /// This type encapsulates both the access and refresh tokens returned
    /// after successful authentication, whether via credentials or token refresh.
    ///
    /// > Important: The access token should be included in subsequent API requests,
    /// > while the refresh token should be securely stored for session renewal.
    public struct Response: Codable, Hashable, Sendable {
        /// The JWT access token for API authentication.
        public let accessToken: String
        
        /// The JWT refresh token for obtaining new access tokens.
        public let refreshToken: String
        
        /// Optional MFA status indicating if further authentication is required.
        public let mfaStatus: MFAStatus?
        
        /// Creates a new authentication response.
        ///
        /// - Parameters:
        ///   - accessToken: The JWT access token
        ///   - refreshToken: The JWT refresh token
        ///   - mfaStatus: Optional MFA status
        public init(
            accessToken: String,
            refreshToken: String,
            mfaStatus: MFAStatus? = nil
        ) {
            self.accessToken = accessToken
            self.refreshToken = refreshToken
            self.mfaStatus = mfaStatus
        }
        
        /// MFA status in authentication response.
        public enum MFAStatus: Codable, Hashable, Sendable {
            /// MFA is not required for this user
            case notRequired
            
            /// MFA was successfully completed
            case satisfied
            
            /// MFA is required but not yet completed
            case pending(sessionToken: String, availableMethods: Set<Identity.MFA.Method>)
        }
    }
}

