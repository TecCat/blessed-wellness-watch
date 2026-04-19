// AppNav.swift — Shared navigation state for pop-to-root
import SwiftUI
import Combine

final class AppNav: ObservableObject {
    @Published var path = NavigationPath()

    /// Clears the entire NavigationStack → returns to HomeView
    func popToRoot() {
        path = NavigationPath()
    }
}
