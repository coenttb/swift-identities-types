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
        
        package init(
            expiration: ExpirationClaim,
            issuedAt: IssuedAtClaim,
            identityId: UUID,
            email: EmailAddress,
            notBefore: NotBeforeClaim? = nil
        ) {
            self.expiration = expiration
            self.issuedAt = issuedAt
            
            // Ensure both ID and email are encoded in subject
            let subjectValue = "\(identityId.uuidString):\(email.rawValue)"
            self.subject = SubjectClaim(value: subjectValue)
            self.notBefore = notBefore
            
            print("JWT.Token.Access init: identityId=\(identityId), email=\(email.rawValue)")
            print("JWT.Token.Access init: subject=\(subjectValue)")
        }
        
        enum CodingKeys: String, CodingKey {
            case expiration = "exp"
            case issuedAt = "iat"
            case subject = "sub"
            case notBefore = "nbf"
        }
    }
}

extension JWT.Token.Access {
    public var identityId: UUID {
        get {
            let components = subject.value.components(separatedBy: ":")
            guard let uuidString = components.first,
                  let uuid = UUID(uuidString: uuidString) else {
                print("ERROR: Invalid UUID in subject: \(subject.value)")
                fatalError("Invalid UUID format in JWT subject")
            }
            return uuid
        }
        set {
            let components = subject.value.components(separatedBy: ":")
            let email = components.count > 1 ? components[1] : ""
            subject.value = "\(newValue.uuidString):\(email)"
        }
    }
    
    public var emailAddress: EmailAddress {
        get {
            let components = subject.value.components(separatedBy: ":")
            if components.count > 1 {
                return EmailAddress(rawValue: components[1])!
            } else {
                print("WARNING: JWT Access token missing email in subject: \(subject.value)")
                return EmailAddress(rawValue: "fallback@example.com")!
            }
        }
        set {
            let components = subject.value.components(separatedBy: ":")
            let id = components.first ?? ""
            subject.value = "\(id):\(newValue.rawValue)"
        }
    }
}

extension JWT.Token.Access: JWTPayload {
    public func verify(using algorithm: some JWTKit.JWTAlgorithm) async throws {
        try self.expiration.verifyNotExpired()
    }
}
