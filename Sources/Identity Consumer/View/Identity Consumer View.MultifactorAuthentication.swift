import Coenttb_Web
import CasePaths
import Identity_Shared

extension Identity.Consumer.View {
    public enum MultifactorAuthentication: Codable, Hashable, Sendable {
        case setup
        case verify 
        case manage 
    }
}
