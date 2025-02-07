// Client.MultifactorAuthentication.live.swift
import Foundation
import Fluent
import Vapor
import Crypto
import Identity_Provider
import EmailAddress

extension Identity.Provider.Client.Authenticate.Multifactor {
    public static func live(
        database: Database,
        logger: Logger,
        sendSMSCode: @escaping @Sendable (String, String) async throws -> Void,
        sendEmailCode: @escaping @Sendable (EmailAddress, String) async throws -> Void,
        generateTOTPSecret: @escaping @Sendable () -> String = { // Default TOTP secret generator
            SymmetricKey(size: .bits256).withUnsafeBytes { Data($0) }.base64EncodedString()
        }
    ) -> Self {
        fatalError()
//        return .init(
//            setup: .init(
//                initialize: { method, identifier async throws -> Identity_Shared.MultifactorAuthentication.Setup.Response in
//                    try await database.transaction { db in
//                        // Verify user exists
//                        guard let _ = try await Identity.find(on: db) else {
//                            throw Abort(.notFound)
//                        }
//                        
//                        // Check if method already exists
//                        if try await MultifactorAuthentication.Method.query(on: db)
//                            .filter(\.$identity.$id == userId)
//                            .filter(\.$type == method)
//                            .first() != nil {
//                            throw Abort(.conflict, reason: "Method already configured")
//                        }
//                        
//                        let mfaMethod = MultifactorAuthentication.Method()
//                        mfaMethod.$identity.id = userId
//                        mfaMethod.type = method
//                        mfaMethod.verified = false
//                        mfaMethod.createdAt = Date()
//                        
//                        switch method {
//                        case .totp:
//                            let secret = generateTOTPSecret()
//                            mfaMethod.identifier = secret
//                            
//                            // Generate recovery codes
//                            let recoveryCodes = try await generateRecoveryCodes(for: on: db)
//                            
//                            try await mfaMethod.save(on: db)
//                            
//                            return .init(secret: secret, recoveryCodes: recoveryCodes)
//                            
//                        case .sms:
//                            guard identifier.range(of: #"^\+[1-9]\d{1,14}$"#, options: .regularExpression) != nil else {
//                                throw Abort(.badRequest, reason: "Invalid phone number")
//                            }
//                            mfaMethod.identifier = identifier
//                            
//                            // Generate and send verification code
//                            let code = try MultifactorAuthentication.generateSecureVerificationCode()
//                            let challenge = MultifactorAuthentication.Challenge()
//                            challenge.$identity.id = userId
//                            challenge.type = .sms
//                            challenge.code = try Bcrypt.hash(code)
//                            challenge.attempts = 0
//                            challenge.createdAt = Date()
//                            challenge.expiresAt = Date().addingTimeInterval(300) // 5 minutes
//                            
//                            try await mfaMethod.save(on: db)
//                            try await challenge.save(on: db)
//                            try await sendSMSCode(identifier, code)
//                            
//                            return .init()
//                            
//                        case .email:
//                            let email = try EmailAddress(identifier)
//                            
//                            mfaMethod.identifier = identifier
//                            
//                            // Generate and send verification code
//                            let code = try MultifactorAuthentication.generateSecureVerificationCode()
//                            let challenge = MultifactorAuthentication.Challenge()
//                            challenge.$identity.id = userId
//                            challenge.type = .email
//                            challenge.code = try Bcrypt.hash(code)
//                            challenge.attempts = 0
//                            challenge.createdAt = Date()
//                            challenge.expiresAt = Date().addingTimeInterval(300) // 5 minutes
//                            
//                            try await mfaMethod.save(on: db)
//                            try await challenge.save(on: db)
//                            try await sendEmailCode(email, code)
//                            
//                            return .init()
//                            
//                        case .recoveryCode:
//                            throw Abort(.badRequest, reason: "Recovery codes cannot be initialized directly")
//                        }
//                    }
//                },
//                confirm: { code async throws -> Void in
//                    try await database.transaction { db in
//                        guard let challenge = try await MultifactorAuthentication.Challenge.query(on: db)
//                            .filter(\.$identity.$id == userId)
//                            .filter(\.$expiresAt > Date())
//                            .first() else {
//                            throw Abort(.notFound, reason: "No active challenge found")
//                        }
//                        
//                        guard challenge.attempts < 3 else {
//                            try await challenge.delete(on: db)
//                            throw Abort(.tooManyRequests, reason: "Too many attempts")
//                        }
//                        
//                        guard try Bcrypt.verify(code, created: challenge.code) else {
//                            challenge.attempts += 1
//                            try await challenge.save(on: db)
//                            throw Abort(.badRequest, reason: "Invalid code")
//                        }
//                        
//                        guard let method = try await MultifactorAuthentication.Method.query(on: db)
//                            .filter(\.$identity.$id == userId)
//                            .filter(\.$type == challenge.type)
//                            .first() else {
//                            throw Abort(.notFound)
//                        }
//                        
//                        method.verified = true
//                        try await method.save(on: db)
//                        try await challenge.delete(on: db)
//                    }
//                },
//                resetSecret: { method in
//                    try await database.transaction { db in
//                        guard let mfaMethod = try await MultifactorAuthentication.Method.query(on: db)
//                            .filter(\.$identity.$id == userId)
//                            .filter(\.$type == method)
//                            .first() else {
//                            throw Abort(.notFound)
//                        }
//                        
//                        // Only allow resetting TOTP secrets
//                        guard method == .totp else {
//                            throw Abort(.badRequest, reason: "Can only reset TOTP secrets")
//                        }
//                        
//                        let newSecret = generateTOTPSecret()
//                        mfaMethod.identifier = newSecret
//                        try await mfaMethod.save(on: db)
//                        
//                        // Log the event
//                        try await MultifactorAuthentication.Audit.Event(
//                            userId: userId.uuidString,
//                            eventType: .methodReset,
//                            method: method,
//                            metadata: ["action": "reset_secret"]
//                        ).save(on: db)
//                        
//                        return newSecret
//                    }
//                }
//            ),
//            verification: .init(
//                createChallenge: { method async throws -> Identity_Shared.MultifactorAuthentication.Challenge in
//                    try await database.transaction { db in
//                        guard let method = try await MultifactorAuthentication.Method.query(on: db)
//                            .filter(\.$identity.$id == userId)
//                            .filter(\.$type == method)
//                            .filter(\.$verified == true)
//                            .first() else {
//                            throw Abort(.notFound, reason: "Method not configured")
//                        }
//                        
//                        let code = try MultifactorAuthentication.generateSecureVerificationCode()
//                        let challenge = MultifactorAuthentication.Challenge()
//                        challenge.$identity.id = userId
//                        challenge.type = method.type
//                        challenge.code = try Bcrypt.hash(code)
//                        challenge.attempts = 0
//                        challenge.createdAt = Date()
//                        challenge.expiresAt = Date().addingTimeInterval(300)
//                        
//                        try await challenge.save(on: db)
//                        
//                        switch method.type {
//                        case .sms:
//                            try await sendSMSCode(method.identifier, code)
//                        case .email:
//                            try await sendEmailCode(.init(method.identifier), code)
//                        case .totp:
//                            // No need to send code for TOTP
//                            break
//                        case .recoveryCode:
//                            throw Abort(.badRequest)
//                        }
//                        
//                        return .init(
//                            id: challenge.id!.uuidString,
//                            method: method.type,
//                            createdAt: challenge.createdAt!,
//                            expiresAt: challenge.expiresAt
//                        )
//                    }
//                },
//                verify: { challengeId, code async throws -> Void in
//                    try await database.transaction { db in
//                        guard let challenge = try await MultifactorAuthentication.Challenge.query(on: db)
//                            .filter(\.$id == UUID(uuidString: challengeId)!)
//                            .filter(\.$identity.$id == userId)
//                            .first() else {
//                            throw Abort(.notFound)
//                        }
//                        
//                        guard challenge.expiresAt > Date() else {
//                            try await challenge.delete(on: db)
//                            throw Abort(.gone, reason: "Challenge expired")
//                        }
//                        
//                        guard challenge.attempts < 3 else {
//                            try await challenge.delete(on: db)
//                            throw Abort(.tooManyRequests)
//                        }
//                        
//                        guard try Bcrypt.verify(code, created: challenge.code) else {
//                            challenge.attempts += 1
//                            try await challenge.save(on: db)
//                            throw Abort(.badRequest, reason: "Invalid code")
//                        }
//                        
//                        try await challenge.delete(on: db)
//                    }
//                },
//                bypass: { challengeId in
//                    try await database.transaction { db in
//                        guard let challengeUUID = UUID(uuidString: challengeId) else {
//                            throw Abort(.badRequest, reason: "Invalid challenge ID format")
//                        }
//                        
//                        guard let challenge = try await MultifactorAuthentication.Challenge.query(on: db)
//                            .filter(\.$id == challengeUUID)
//                            .filter(\.$identity.$id == userId)
//                            .first() else {
//                            throw Abort(.notFound)
//                        }
//                        
//                        // Log the bypass
//                        try await MultifactorAuthentication.Audit.Event(
//                            userId: userId.uuidString,
//                            eventType: .bypassUsed,
//                            method: challenge.type,
//                            metadata: [
//                                "challengeId": challengeId,
//                                "bypassedAt": ISO8601DateFormatter().string(from: Date())
//                            ]
//                        ).save(on: db)
//                        
//                        try await challenge.delete(on: db)
//                    }
//                }
//            ),
//            
//            recovery: .init(
//                generateNewCodes: { userId async throws -> [String] in
//                    try await generateRecoveryCodes(for: on: database)
//                },
//                
//                getRemainingCodeCount: { userId async throws -> Int in
//                    try await MultifactorAuthentication.RecoveryCode.query(on: database)
//                        .filter(\.$identity.$id == userId)
//                        .filter(\.$used == false)
//                        .count()
//                },
//                getUsedCodes: { userId in // Add missing method
//                    let codes = try await MultifactorAuthentication.RecoveryCode.query(on: database)
//                        .filter(\.$identity.$id == userId)
//                        .filter(\.$used == true)
//                        .all()
//                    return Set(codes.map(\.code))
//                }
//            ),
//            administration: .init(
//                forceDisable: { userId in
//                    try await database.transaction { db in
//                        try await MultifactorAuthentication.Method.query(on: db)
//                            .filter(\.$identity.$id == userId)
//                            .delete()
//                        try await MultifactorAuthentication.RecoveryCode.query(on: db)
//                            .filter(\.$identity.$id == userId)
//                            .delete()
//                        
//                        // Log audit event
//                        try await MultifactorAuthentication.Audit.Event(
//                            userId: userId.uuidString,
//                            eventType: .forceDisabled
//                        ).save(on: db)
//                    }
//                },
//                getAuditLog: { startDate, endDate in
//                    try await MultifactorAuthentication.Audit.Event.query(on: database)
//                        .filter(\.$userId == userId.uuidString)
//                        .filter(\.$timestamp >= startDate)
//                        .filter(\.$timestamp <= endDate)
//                        .sort(\.$timestamp, .descending)
//                        .all()
//                        .map(Identity_Shared.MultifactorAuthentication.Audit.Event.init)
//                        
//                },
//                bulkDisable: { userIds in
//                    var results: [UUID: Error?] = [:]
//                    for userId in userIds {
//                        do {
//                            try await database.transaction { db in
//                                try await MultifactorAuthentication.Method.query(on: db)
//                                    .filter(\.$identity.$id == userId)
//                                    .delete()
//                                try await MultifactorAuthentication.RecoveryCode.query(on: db)
//                                    .filter(\.$identity.$id == userId)
//                                    .delete()
//                                
//                                // Log audit event
//                                try await MultifactorAuthentication.Audit.Event(
//                                    userId: userId.uuidString,
//                                    eventType: .forceDisabled
//                                ).save(on: db)
//                            }
//                            results[userId] = nil
//                        } catch {
//                            results[userId] = error
//                        }
//                    }
//                    return results
//                },
//                getStatus: { userIds in
//                    var results: [UUID: Identity_Shared.MultifactorAuthentication.Status] = [:]
//                    for userId in userIds {
//                        let methods = try await MultifactorAuthentication.Method.query(on: database)
//                            .filter(\.$identity.$id == userId)
//                            .filter(\.$verified == true)
//                            .all()
//                        results[userId] = methods.isEmpty ? .disabled : .enabled
//                    }
//                    return results
//                }
//            )
//        )
    }
}
//
//// In the recovery codes generation function:
//private func generateRecoveryCodes(for userId: UUID, on database: Database) async throws -> [String] {
//    // Delete existing unused recovery codes
//    try await MultifactorAuthentication.RecoveryCode.query(on: database)
//        .filter(\.$identity.$id == userId)
//        .filter(\.$used == false)
//        .delete()
//    
//    // Generate new codes
//    let codes = try (0..<10).map { _ in
//        try MultifactorAuthentication.generateSecureRecoveryCode()
//    }
//    
//    // Save hashed codes
//    for code in codes {
//        let recoveryCode = MultifactorAuthentication.RecoveryCode()
//        recoveryCode.$identity.id = userId
//        recoveryCode.code = try Bcrypt.hash(code)
//        recoveryCode.used = false
//        try await recoveryCode.save(on: database)
//    }
//    
//    return codes
//}
//
//extension MultifactorAuthentication {
//    // Generate a secure random number within a range
//    static func secureRandomNumber(min: Int, max: Int) throws -> Int {
//        guard min < max else {
//            throw SecureRandomError.invalidRange
//        }
//        
//        let range = UInt64(max - min + 1)
//        var random = SystemRandomNumberGenerator()
//        
//        // Generate random number using uniform distribution to avoid modulo bias
//        let secureRandom = random.next(upperBound: range)
//        return Int(secureRandom) + min
//    }
//    
//    // Generate a secure verification code
//    static func generateSecureVerificationCode() throws -> String {
//        // Generate 6 random digits (100000-999999)
//        let secureNumber = try secureRandomNumber(min: 100000, max: 999999)
//        return String(secureNumber)
//    }
//    
//    // Generate a secure recovery code segment
//    static func generateSecureRecoveryCode() throws -> String {
//        // Generate 5 random digits for each recovery code
//        return try (0..<5).map { _ in
//            String(try secureRandomNumber(min: 0, max: 9))
//        }.joined()
//    }
//}
//
//enum SecureRandomError: Error {
//    case invalidRange
//}
