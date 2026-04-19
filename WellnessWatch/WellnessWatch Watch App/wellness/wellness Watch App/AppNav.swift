// AppNav.swift — Shared navigation state for pop-to-root
import SwiftUI
import Combine

final class AppNav: ObservableObject {

    /// Each view in the stack watches this; when true it calls dismiss()
    @Published var shouldPopToRoot = false

    /// Broadcast pop-to-root, then reset flag after navigation completes
    func popToRoot() {
        shouldPopToRoot = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.shouldPopToRoot = false
        }
    }
}
