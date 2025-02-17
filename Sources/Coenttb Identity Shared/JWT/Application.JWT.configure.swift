//
//  File.swift
//  coenttb-identity
//
//  Created by Coen ten Thije Boonkkamp on 07/02/2025.
//

import Coenttb_Vapor
import JWT

extension Application.JWT {
    public static func configure(
        application: Application,
        privateKey: String?,
        publicKey: String
    ) async throws {
        if let privateKeyString = privateKey {
            let privateKey = try EdDSA.PrivateKey(
                d: privateKeyString,
                curve: .ed25519
            )
            await application.jwt.keys.add(eddsa: privateKey)
        }

        let publicKey = try EdDSA.PublicKey(
            x: publicKey,
            curve: .ed25519
        )
        await application.jwt.keys.add(eddsa: publicKey)

#if DEBUG
        if privateKey == nil {
            let key = try EdDSA.PrivateKey(curve: .ed25519)
            await application.jwt.keys.add(eddsa: key)

            print("Development JWT Keys - DO NOT USE IN PRODUCTION")
            print("Private Key (d):", String(describing: key))
            print("Public Key (x):", String(describing: key))
        }
#endif
    }
}
