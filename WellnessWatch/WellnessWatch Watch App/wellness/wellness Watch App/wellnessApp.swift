//
//  wellnessApp.swift
//  wellness Watch App
//
//  Created by HT on 4/17/26.
//

import SwiftUI
import SwiftData

@main
struct wellness_Watch_AppApp: App {

    @StateObject private var nav = AppNav()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .environmentObject(nav)
        }
        .modelContainer(for: SessionRecord.self)
    }
}
