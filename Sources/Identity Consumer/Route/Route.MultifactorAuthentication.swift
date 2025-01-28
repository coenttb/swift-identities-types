import Coenttb_Web
import CasePaths
import Identity_Shared

extension Route {
    public enum MultifactorAuthentication: Codable, Hashable, Sendable {
        case setup     // MFA setup page
        case verify    // MFA verification page during login
        case manage    // MFA management page (enable/disable methods, generate recovery codes)
    }
}
