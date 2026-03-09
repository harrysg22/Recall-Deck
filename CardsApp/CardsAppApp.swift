//
//  CardsAppApp.swift
//  CardsApp
//

import SwiftUI
import SwiftData

@main
struct CardsAppApp: App {
    @StateObject private var ttsService = TTSService()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Deck.self, Card.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            DeckListView()
                .environmentObject(ttsService)
        }
        .modelContainer(sharedModelContainer)
    }
}
