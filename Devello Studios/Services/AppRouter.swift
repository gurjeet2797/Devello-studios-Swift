import Combine
import SwiftUI

@MainActor
final class AppRouter: ObservableObject {
    @Published var path: [Route] = []

    enum Route: Hashable {
        case lighting
        case editor
    }

    func navigate(to route: Route) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            path.append(route)
        }
    }

    func popToRoot() {
        guard !path.isEmpty else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            path.removeAll()
        }
    }
}
