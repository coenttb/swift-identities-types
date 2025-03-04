//
//  File.swift
//  coenttb-identities
//
//  Created by Coen ten Thije Boonkkamp on 10/10/2024.
//

import Coenttb_Web
import Identities
import Mailgun
import Messages

extension Email {
    public init(
        business: BusinessDetails,
        emailChange: Email.Change
    ) {
        switch emailChange {
        case .confirmation(let confirmation):
            switch confirmation {
            case .request(let request):
                self = .init(
                    business: business,
                    emailChangeConfirmationRequest: request
                )
            case .notification(let notification):
                self = .init(
                    business: business,
                    emailChangeConfirmationNotification: notification
                )
            }

        case .request(let request):
            switch request {
            case .notification(let notification):
                self = .init(
                    business: business,
                    emailChangeRequestNotification: notification
                )
            }
        }
    }
}

extension Email {
    public enum Change {
        case confirmation(Email.Change.Confirmation)
        case request(Email.Change.Request)
    }
}

extension Email.Change {
    public enum Request {
        case notification(Email.Change.Request.Notification)
    }
}

extension Email.Change {
    public enum Confirmation: Sendable {
        case request(Email.Change.Confirmation.Request)
        case notification(Email.Change.Confirmation.Notification)
    }
}

extension Email.Change.Confirmation {
    public struct Request: Sendable {
        public let verificationURL: URL
        public let currentEmail: EmailAddress
        public let newEmail: EmailAddress
        public let userName: String?

        public init(
            verificationURL: URL,
            currentEmail: EmailAddress,
            newEmail: EmailAddress,
            userName: String?
        ) {
            self.verificationURL = verificationURL
            self.currentEmail = currentEmail
            self.newEmail = newEmail
            self.userName = userName
        }
    }
}

extension Email.Change.Request {
    public struct Notification: Sendable {
        public let currentEmail: EmailAddress
        public let newEmail: EmailAddress
        public let userName: String?

        public init(
            currentEmail: EmailAddress,
            newEmail: EmailAddress,
            userName: String?
        ) {
            self.currentEmail = currentEmail
            self.newEmail = newEmail
            self.userName = userName
        }
    }
}

extension Email.Change.Confirmation {
    public enum Notification: Sendable {
        case currentEmail(CurrentEmail)
        case newEmail(NewEmail)

        public struct Payload: Sendable {
            public let currentEmail: EmailAddress
            public let newEmail: EmailAddress
            public let userName: String?

            public init(
                currentEmail: EmailAddress,
                newEmail: EmailAddress,
                userName: String?
            ) {
                self.currentEmail = currentEmail
                self.newEmail = newEmail
                self.userName = userName
            }
        }

        public typealias CurrentEmail = Payload
        public typealias NewEmail = Payload
    }
}

extension Email {
    public init(
        business: BusinessDetails,
        emailChangeRequestNotification: Email.Change.Request.Notification
    ) {
        let html = TableEmailDocument(
            preheader: TranslatedString(
                dutch: "Er is een verzoek ingediend om je e-mailadres te wijzigen voor \(business.name)",
                english: "A request has been made to change your email address for \(business.name)"
            ).description
        ) {
            tr {
                td {
                    VStack(alignment: .leading) {
                        Header(3) {
                            TranslatedString(
                                dutch: "Verzoek tot e-mailwijziging ontvangen",
                                english: "Email Change Request Received"
                            )
                        }

                        Paragraph {
                            TranslatedString(
                                dutch: "We hebben een verzoek ontvangen om het e-mailadres voor je \(business.name) account te wijzigen van \(emailChangeRequestNotification.currentEmail) naar \(emailChangeRequestNotification.newEmail).",
                                english: "We received a request to change the email address for your \(business.name) account from \(emailChangeRequestNotification.currentEmail) to \(emailChangeRequestNotification.newEmail)."
                            )
                        }
                        .padding(bottom: .extraSmall)
                        .fontSize(.body)

                        Paragraph {
                            TranslatedString(
                                dutch: "Als je dit verzoek hebt gedaan, hoef je verder niets te doen. De wijziging wordt binnenkort doorgevoerd.",
                                english: "If you made this request, no further action is needed. The change will be processed shortly."
                            )
                        }
                        .padding(bottom: .extraSmall)
                        .fontSize(.body)

                        Paragraph(.small) {
                            TranslatedString(
                                dutch: "Als je dit verzoek niet hebt gedaan, neem dan onmiddellijk contact op met ons via \(business.supportEmail) om je account te beveiligen.",
                                english: "If you didn't request this change, please contact us immediately at \(business.supportEmail) to secure your account."
                            )
                        }
                        .fontSize(.footnote)
                        .color(.secondary)
                    }
                    .padding(vertical: .small, horizontal: .medium)
                }
            }
        }
            .backgroundColor(.primary.reverse())

        let bytes: ContiguousArray<UInt8> = html.render()
        let string: String = String(decoding: bytes, as: UTF8.self)

        let subjectAdd = TranslatedString(
            dutch: "Belangrijk: Verzoek tot e-mailwijziging ontvangen",
            english: "Important: Email Change Request Received"
        )

        self = .init(
            from: business.fromEmail,
            to: [
                //                emailChangeRequestNotification.userName.map { name in "\(name) <\(emailChangeRequestNotification.currentEmail.rawValue)>" } ?? "\(emailChangeRequestNotification.currentEmail.rawValue)"
                emailChangeRequestNotification.currentEmail
            ],
            subject: "\(business.name) | \(subjectAdd)",
            html: string,
            text: nil
        )
    }
}

extension Email {
    public init(
        business: BusinessDetails,
        emailChangeConfirmationRequest: Email.Change.Confirmation.Request
    ) {
        let html = TableEmailDocument(
            preheader: TranslatedString(
                dutch: "Verifieer je nieuwe e-mailadres voor \(business.name)",
                english: "Verify your new email address for \(business.name)"
            ).description
        ) {
            tr {
                td {
                    VStack(alignment: .leading) {
                        Header(3) {
                            TranslatedString(
                                dutch: "Verifieer je nieuwe e-mailadres",
                                english: "Verify your new email address"
                            )
                        }

                        Paragraph {
                            TranslatedString(
                                dutch: "We hebben een verzoek ontvangen om het e-mailadres voor je \(business.name) account te wijzigen. Klik op de onderstaande knop om je nieuwe e-mailadres te verifiëren.",
                                english: "We received a request to change the email address for your \(business.name) account. Click the button below to verify your new email address."
                            )
                        }
                        .padding(bottom: .extraSmall)
                        .fontSize(.body)

                        Button(
                            tag: a,
                            background: business.primaryColor
                        ) {
                            TranslatedString(
                                dutch: "Verifieer e-mailadres",
                                english: "Verify email address"
                            )
                        }
                        .color(.primary.reverse())
                        .href(emailChangeConfirmationRequest.verificationURL.absoluteString)
                        .padding(bottom: Length.medium)

                        Paragraph(.small) {
                            TranslatedString(
                                dutch: "Deze link verloopt binnen 1 uur om veiligheidsredenen.",
                                english: "This link will expire in 1 hour for security reasons."
                            )

                            TranslatedString(
                                dutch: "Als je geen wijziging van je e-mailadres hebt aangevraagd, kun je deze e-mail negeren.",
                                english: "If you didn't request an email address change, you can ignore this email."
                            )

                            br()

                            TranslatedString(
                                dutch: "Voor hulp, neem contact op met ons via \(business.supportEmail).",
                                english: "For help, contact us at \(business.supportEmail)."
                            )
                        }
                        .fontSize(.footnote)
                        .color(.secondary)
                    }
                    .padding(vertical: .small, horizontal: .medium)
                }
            }
        }
            .backgroundColor(.primary.reverse())

        let bytes: ContiguousArray<UInt8> = html.render()
        let string: String = String(decoding: bytes, as: UTF8.self)

        let subjectAdd = TranslatedString(
            dutch: "Verifieer je e-mailadres",
            english: "Verify your email address"
        )

        self = .init(
            from: business.fromEmail,
            to: [
                //                emailChangeConfirmationRequest.userName.map { name in "\(name) <\(emailChangeConfirmationRequest.newEmail.rawValue)>" } ?? "\(emailChangeConfirmationRequest.newEmail.rawValue)"
                emailChangeConfirmationRequest.newEmail
            ],
            subject: "\(business.name) | \(subjectAdd)",
            html: string,
            text: nil
        )
    }
}

extension Email {
    public init(
        business: BusinessDetails,
        emailChangeConfirmationNotification: Email.Change.Confirmation.Notification
    ) {
        switch emailChangeConfirmationNotification {
        case .currentEmail(let notification):
            let html = TableEmailDocument(
                preheader: TranslatedString(
                    dutch: "Je e-mailadres voor \(business.name) is gewijzigd",
                    english: "Your email address for \(business.name) has been changed"
                ).description
            ) {
                tr {
                    td {
                        VStack(alignment: .leading) {
                            Header(3) {
                                TranslatedString(
                                    dutch: "Je e-mailadres is gewijzigd",
                                    english: "Your email address has been changed"
                                )
                            }

                            Paragraph {
                                TranslatedString(
                                    dutch: "We willen je informeren dat het e-mailadres voor je \(business.name) account is gewijzigd van \(notification.currentEmail.rawValue) naar \(notification.newEmail.rawValue).",
                                    english: "We're informing you that the email address for your \(business.name) account has been changed from \(notification.currentEmail.rawValue) to \(notification.newEmail.rawValue)."
                                )
                            }
                            .padding(bottom: .extraSmall)
                            .fontSize(.body)

                            Paragraph {
                                TranslatedString(
                                    dutch: "Als je deze wijziging hebt aangevraagd, kun je deze e-mail als bevestiging beschouwen. Je kunt nu inloggen met je nieuwe e-mailadres.",
                                    english: "If you requested this change, please consider this email as confirmation. You can now log in using your new email address."
                                )
                            }
                            .padding(bottom: .extraSmall)
                            .fontSize(.body)

                            Paragraph(.small) {
                                TranslatedString(
                                    dutch: "Als je deze wijziging niet hebt aangevraagd, neem dan onmiddellijk contact op met ons via \(business.supportEmail) om je account te beveiligen.",
                                    english: "If you didn't request this change, please contact us immediately at \(business.supportEmail) to secure your account."
                                )
                            }
                            .fontSize(.footnote)
                            .color(.secondary)
                        }
                        .padding(vertical: .small, horizontal: .medium)
                    }
                }
            }
                .backgroundColor(.primary.reverse())

            let bytes: ContiguousArray<UInt8> = html.render()
            let string: String = String(decoding: bytes, as: UTF8.self)

            let subjectAdd = TranslatedString(
                dutch: "Belangrijk: Je e-mailadres is gewijzigd",
                english: "Important: Your email address has been changed"
            )

            self = .init(
                from: business.fromEmail,
                to: [
                    //                    notification.userName.map { name in "\(name) <\(notification.currentEmail.rawValue)>" } ?? "\(notification.currentEmail.rawValue)"
                    notification.currentEmail
                ],
                subject: "\(business.name) | \(subjectAdd)",
                html: string,
                text: nil
            )

        case .newEmail(let notification):
            let html = TableEmailDocument(
                preheader: TranslatedString(
                    dutch: "Je nieuwe e-mailadres voor \(business.name) is bevestigd",
                    english: "Your new email address for \(business.name) is confirmed"
                ).description
            ) {
                tr {
                    td {
                        VStack(alignment: .leading) {
                            Header(3) {
                                TranslatedString(
                                    dutch: "Je nieuwe e-mailadres is bevestigd",
                                    english: "Your new email address is confirmed"
                                )
                            }

                            Paragraph {
                                TranslatedString(
                                    dutch: "Welkom! We bevestigen dat dit e-mailadres (\(notification.newEmail.rawValue)) nu is gekoppeld aan je \(business.name) account. Je vorige e-mailadres was \(notification.currentEmail.rawValue).",
                                    english: "Welcome! We confirm that this email address (\(notification.newEmail.rawValue)) is now associated with your \(business.name) account. Your previous email address was \(notification.currentEmail.rawValue)."
                                )
                            }
                            .padding(bottom: .extraSmall)
                            .fontSize(.body)

                            Paragraph {
                                TranslatedString(
                                    dutch: "Je kunt nu inloggen op je account met dit nieuwe e-mailadres. Al je accountgegevens en voorkeuren blijven ongewijzigd.",
                                    english: "You can now log in to your account using this new email address. All your account details and preferences remain unchanged."
                                )
                            }
                            .padding(bottom: .extraSmall)
                            .fontSize(.body)

                            Paragraph(.small) {
                                TranslatedString(
                                    dutch: "Als je deze wijziging niet hebt aangevraagd of als je vragen hebt, neem dan contact op met ons via \(business.supportEmail).",
                                    english: "If you didn't request this change or if you have any questions, please contact us at \(business.supportEmail)."
                                )
                            }
                            .fontSize(.footnote)
                            .color(.secondary)
                        }
                        .padding(vertical: .small, horizontal: .medium)
                    }
                }
            }
                .backgroundColor(.primary.reverse())

            let bytes: ContiguousArray<UInt8> = html.render()
            let string: String = String(decoding: bytes, as: UTF8.self)

            let subjectAdd = TranslatedString(
                dutch: "Je nieuwe e-mailadres is bevestigd",
                english: "Your new email address is confirmed"
            )

            self = .init(
                from: business.fromEmail,
                to: [
                    //                    notification.userName.map { name in "\(name) <\(notification.newEmail.rawValue)>" } ?? "\(notification.newEmail.rawValue)"
                    notification.newEmail
                ],
                subject: "\(business.name) | \(subjectAdd)",
                html: string,
                text: nil
            )
        }
    }
}
