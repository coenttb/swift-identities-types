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
        
        package init(
            expiration: ExpirationClaim,
            issuedAt: IssuedAtClaim,
            identityId: UUID,
            email: EmailAddress
        ) {
            self.expiration = expiration
            self.issuedAt = issuedAt
            self.subject = SubjectClaim(value: "\(identityId.uuidString):\(email.rawValue)")
        }
        
        enum CodingKeys: String, CodingKey {
            case expiration = "exp"
            case issuedAt = "iat"
            case subject = "sub"
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
            guard components.count > 1,
                  !components[1].isEmpty,
                  let email = EmailAddress(rawValue: components[1]) else {
                print("ERROR: Missing or invalid email in subject: \(subject.value)")
                fatalError("Missing or invalid email in JWT subject")
            }
            return email
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
        @Dependency(\.date) var date
        try self.expiration.verifyNotExpired(currentDate: date())
    }
}
