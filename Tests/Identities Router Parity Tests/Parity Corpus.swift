// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-foundations open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-foundations
// project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

enum ParityCorpus {
    static subscript(_ name: String) -> String? {
        documents[name]
    }

    private static let documents: [String: String] = [
        "Authentication": ##########"""
        == api.credentials ==
        method: POST
        path: /api/authenticate
        header: content-type: application/x-www-form-urlencoded
        body(utf8): password=secret1234&username=user%40example.com

        == api.token.access ==
        method: POST
        path: /api/authenticate/access
        header: cookie: access_token="eyJhbGciOiJub25lIn0.eyJzdWIiOiJwYXJpdHkifQ.AQID"
        body: <nil>

        == api.token.refresh ==
        method: POST
        path: /api/authenticate/refresh
        header: content-type: application/json
        body(utf8): "eyJhbGciOiJub25lIn0.eyJzdWIiOiJwYXJpdHkifQ.AQID"

        == api.apiKey ==
        method: <nil>
        path: /api/authenticate/api-key
        header: authorization: Bearer parity-token-123
        body: <nil>

        == view.credentials ==
        method: <nil>
        path: /login
        body: <nil>
        """########## + "\n",
        "Creation": ##########"""
        == api.request ==
        method: POST
        path: /api/create/request
        header: content-type: application/x-www-form-urlencoded
        body(utf8): email=user%40example.com&password=secret1234

        == api.verify ==
        method: POST
        path: /api/create/verify
        header: content-type: application/x-www-form-urlencoded
        body(utf8): email=user%40example.com&token=verify-token-123

        == view.request ==
        method: <nil>
        path: /create/request
        body: <nil>

        == view.verify ==
        method: <nil>
        path: /create/verify
        query: token=verify-token-123
        query: email=user@example.com
        body: <nil>
        """########## + "\n",
        "Deletion": ##########"""
        == api.request ==
        method: POST
        path: /api/delete/request
        header: content-type: application/x-www-form-urlencoded
        body(utf8): reauthToken=reauth-token-123

        == api.cancel ==
        method: POST
        path: /api/delete/cancel
        body: <nil>

        == api.confirm ==
        method: POST
        path: /api/delete/confirm
        body: <nil>

        == view.request ==
        method: <nil>
        path: /delete
        body: <nil>
        """########## + "\n",
        "Email": ##########"""
        == api.change.request ==
        method: POST
        path: /api/email/request
        header: content-type: application/x-www-form-urlencoded
        body(utf8): newEmail=new%40example.com

        == api.change.confirm ==
        method: POST
        path: /api/email/confirm
        header: content-type: application/x-www-form-urlencoded
        body(utf8): token=email-token-123

        == view.change.request ==
        method: <nil>
        path: /email/change/request
        body: <nil>

        == view.change.confirm ==
        method: POST
        path: /email/change/confirm/confirm
        header: content-type: application/x-www-form-urlencoded
        body(utf8): token=email-token-123

        == view.change.reauthorization ==
        method: <nil>
        path: /email/change
        body: <nil>
        """########## + "\n",
        "Facade API": ##########"""
        == authenticate.credentials ==
        method: POST
        path: /authenticate
        header: content-type: application/x-www-form-urlencoded
        body(utf8): password=secret1234&username=user%40example.com

        == reauthorize ==
        method: POST
        path: /reauthorize
        header: content-type: application/x-www-form-urlencoded
        body(utf8): password=secret1234

        == create.request ==
        method: POST
        path: /create/request
        header: content-type: application/x-www-form-urlencoded
        body(utf8): email=user%40example.com&password=secret1234

        == delete.cancel ==
        method: POST
        path: /delete/cancel
        body: <nil>

        == logout.current ==
        method: POST
        path: /logout
        body: <nil>

        == email.change.request ==
        method: POST
        path: /email/request
        header: content-type: application/x-www-form-urlencoded
        body(utf8): newEmail=new%40example.com

        == password.reset.request ==
        method: POST
        path: /password/reset/request
        header: content-type: application/x-www-form-urlencoded
        body(utf8): email=user%40example.com

        == mfa.status.get ==
        method: GET
        path: /reset/status
        body: <nil>

        == oauth.providers ==
        method: GET
        path: /reset/providers
        body: <nil>
        """########## + "\n",
        "Facade View": ##########"""
        == authenticate.credentials ==
        method: <nil>
        path: /login
        body: <nil>

        == create.request ==
        method: <nil>
        path: /create/request
        body: <nil>

        == delete.request ==
        method: <nil>
        path: /delete
        body: <nil>

        == logout ==
        method: <nil>
        path: /logout
        body: <nil>

        == email.change.request ==
        method: <nil>
        path: /email/change/request
        body: <nil>

        == password.reset.request ==
        method: <nil>
        path: /password/reset/request
        body: <nil>

        == mfa.manage ==
        method: <nil>
        path: /mfa/manage
        body: <nil>

        == oauth.login ==
        method: GET
        path: /oauth/login
        body: <nil>
        """########## + "\n",
        "Logout": ##########"""
        == api.current ==
        method: POST
        path: /logout
        body: <nil>

        == api.all ==
        method: POST
        path: /logout/all
        body: <nil>

        == view ==
        method: <nil>
        path: /logout
        body: <nil>
        """########## + "\n",
        "MFA": ##########"""
        == api.totp.setup ==
        method: POST
        path: /api/mfa/totp/setup
        body: <nil>

        == api.totp.confirmSetup ==
        method: POST
        path: /api/mfa/totp/confirm
        header: content-type: application/x-www-form-urlencoded
        body(utf8): code=123456

        == api.totp.verify ==
        method: POST
        path: /api/mfa/totp/verify
        header: content-type: application/json
        body(utf8/sorted-keys): {"code":"123456","sessionToken":"session-token-123"}

        == api.totp.disable ==
        method: POST
        path: /api/mfa/totp/disable
        header: content-type: application/json
        body(utf8/sorted-keys): {"reauthorizationToken":"reauth-token-123"}

        == api.sms.setup ==
        method: POST
        path: /api/mfa/sms/setup
        header: content-type: application/json
        body(utf8/sorted-keys): {"phoneNumber":"+15555550100"}

        == api.sms.requestCode ==
        method: POST
        path: /api/mfa/sms/request
        body: <nil>

        == api.sms.verify ==
        method: POST
        path: /api/mfa/sms/verify
        header: content-type: application/json
        body(utf8/sorted-keys): {"code":"123456","sessionToken":"session-token-123"}

        == api.sms.updatePhoneNumber ==
        method: POST
        path: /api/mfa/sms/update
        header: content-type: application/json
        body(utf8/sorted-keys): {"phoneNumber":"+15555550101","reauthorizationToken":"reauth-token-123"}

        == api.sms.disable ==
        method: POST
        path: /api/mfa/sms/disable
        header: content-type: application/json
        body(utf8/sorted-keys): {"reauthorizationToken":"reauth-token-123"}

        == api.email.setup ==
        method: POST
        path: /api/mfa/email/setup
        header: content-type: application/json
        body(utf8/sorted-keys): {"email":"mfa@example.com"}

        == api.email.requestCode ==
        method: POST
        path: /api/mfa/email/request
        body: <nil>

        == api.email.verify ==
        method: POST
        path: /api/mfa/email/verify
        header: content-type: application/json
        body(utf8/sorted-keys): {"code":"123456","sessionToken":"session-token-123"}

        == api.email.updateEmail ==
        method: POST
        path: /api/mfa/email/update
        header: content-type: application/json
        body(utf8/sorted-keys): {"email":"mfa2@example.com","reauthorizationToken":"reauth-token-123"}

        == api.email.disable ==
        method: POST
        path: /api/mfa/email/disable
        header: content-type: application/json
        body(utf8/sorted-keys): {"reauthorizationToken":"reauth-token-123"}

        == api.webauthn.beginRegistration ==
        method: POST
        path: /api/mfa/webauthn/register/begin
        body: <nil>

        == api.webauthn.finishRegistration ==
        method: POST
        path: /api/mfa/webauthn/register/finish
        header: content-type: application/json
        body(utf8/sorted-keys): {"credentialName":"parity-key","response":"attestation-response"}

        == api.webauthn.beginAuthentication ==
        method: POST
        path: /api/mfa/webauthn/authenticate/begin
        body: <nil>

        == api.webauthn.finishAuthentication ==
        method: POST
        path: /api/mfa/webauthn/authenticate/finish
        header: content-type: application/json
        body(utf8/sorted-keys): {"response":"assertion-response","sessionToken":"session-token-123"}

        == api.webauthn.listCredentials ==
        method: GET
        path: /api/mfa/webauthn/credentials
        body: <nil>

        == api.webauthn.removeCredential ==
        method: POST
        path: /api/mfa/webauthn/credentials/remove
        header: content-type: application/json
        body(utf8/sorted-keys): {"credentialId":"credential-123","reauthorizationToken":"reauth-token-123"}

        == api.webauthn.disable ==
        method: POST
        path: /api/mfa/webauthn/disable
        header: content-type: application/json
        body(utf8/sorted-keys): {"reauthorizationToken":"reauth-token-123"}

        == api.backupCodes.regenerate ==
        method: POST
        path: /api/mfa/backup-codes/regenerate
        body: <nil>

        == api.backupCodes.verify ==
        method: POST
        path: /api/mfa/backup-codes/verify
        header: content-type: application/json
        body(utf8/sorted-keys): {"code":"backup-code-1","sessionToken":"session-token-123"}

        == api.backupCodes.remaining ==
        method: GET
        path: /api/mfa/backup-codes/remaining
        body: <nil>

        == api.status.get ==
        method: GET
        path: /api/mfa/status
        body: <nil>

        == api.status.challenge ==
        method: GET
        path: /api/mfa/status/challenge
        body: <nil>

        == api.verify ==
        method: POST
        path: /api/mfa/verify
        header: content-type: application/x-www-form-urlencoded
        body(utf8): code=123456&method=totp&sessionToken=session-token-123

        == view.verify ==
        method: <nil>
        path: /mfa/verify
        query: sessionToken=session-token-123
        body: <nil>

        == view.manage ==
        method: <nil>
        path: /mfa/manage
        body: <nil>

        == view.totp.setup ==
        method: <nil>
        path: /mfa/totp/setup
        body: <nil>

        == view.totp.confirmSetup ==
        method: <nil>
        path: /mfa/totp/confirm-setup
        body: <nil>

        == view.totp.manage ==
        method: <nil>
        path: /mfa/totp/manage
        body: <nil>

        == view.backupCodes.display ==
        method: <nil>
        path: /mfa/backup-codes/display
        body: <nil>

        == view.backupCodes.verify ==
        method: <nil>
        path: /mfa/backup-codes/verify
        query: sessionToken=session-token-123
        body: <nil>
        """########## + "\n",
        "OAuth": ##########"""
        == api.providers ==
        method: GET
        path: /api/oauth/providers
        body: <nil>

        == api.authorize ==
        method: GET
        path: /api/oauth/authorize/github
        body: <nil>

        == api.callback ==
        method: GET
        path: /api/oauth/callback
        query: code=oauth-code-123
        query: state=oauth-state-123
        body: <nil>

        == api.connections ==
        method: GET
        path: /api/oauth/connections
        body: <nil>

        == api.disconnect ==
        method: DELETE
        path: /api/oauth/disconnect/github
        body: <nil>

        == view.login ==
        method: GET
        path: /oauth/login
        body: <nil>

        == view.callback ==
        method: GET
        path: /oauth/callback
        query: code=oauth-code-123
        query: state=oauth-state-123
        body: <nil>

        == view.connections ==
        method: GET
        path: /oauth/connections
        body: <nil>

        == view.error ==
        method: GET
        path: /oauth/error
        query: message=parity-error
        body: <nil>
        """########## + "\n",
        "Password": ##########"""
        == api.reset.request ==
        method: POST
        path: /api/password/reset/request
        header: content-type: application/x-www-form-urlencoded
        body(utf8): email=user%40example.com

        == api.reset.confirm ==
        method: POST
        path: /api/password/reset/confirm
        header: content-type: application/x-www-form-urlencoded
        body(utf8): newPassword=newSecret1&token=reset-token-123

        == api.change.request ==
        method: POST
        path: /api/password/change/request
        header: content-type: application/x-www-form-urlencoded
        body(utf8): currentPassword=secret1234&newPassword=newSecret1

        == view.reset.request ==
        method: <nil>
        path: /password/reset/request
        body: <nil>

        == view.reset.confirm ==
        method: POST
        path: /password/reset/confirm/confirm
        header: content-type: application/x-www-form-urlencoded
        body(utf8): newPassword=newSecret1&token=reset-token-123

        == view.change.request ==
        method: <nil>
        path: /password/change/request
        body: <nil>
        """########## + "\n",
        "Reauthorization": ##########"""
        == api.request ==
        method: POST
        path: /api/reauthorize
        header: content-type: application/x-www-form-urlencoded
        body(utf8): password=secret1234
        """########## + "\n",
    ]
}
