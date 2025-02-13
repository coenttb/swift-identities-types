import CasePaths
import Coenttb_Web
import Identity_Shared

extension Identity.Consumer.View.Authenticate {
    public enum Multifactor: Codable, Hashable, Sendable {
        case setup
        case verify
        case manage
    }
}
