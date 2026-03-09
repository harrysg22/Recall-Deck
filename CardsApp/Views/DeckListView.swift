//
//  DeckListView.swift
//  CardsApp
//

import SwiftUI
import SwiftData

struct DeckListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Deck.createdAt, order: .reverse) private var decks: [Deck]
    @State private var showingAddDeck = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("reviewReminderHour") private var reviewReminderHour: Int = 20
    @AppStorage("reviewReminderMinute") private var reviewReminderMinute: Int = 0

    var body: some View {
        NavigationStack {
            Group {
                if decks.isEmpty {
                    ContentUnavailableView(
                        "No hay mazos",
                        systemImage: "rectangle.stack.badge.plus",
                        description: Text("Crea un mazo para empezar a aprender vocabulario.")
                    )
                } else {
                    List {
                        ForEach(decks) { deck in
                            NavigationLink(value: deck) {
                                DeckRowView(deck: deck)
                            }
                        }
                        .onDelete(perform: deleteDecks)
                    }
                }
            }
            .navigationTitle("Mazos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddDeck = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(value: "settings") {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .navigationDestination(for: Deck.self) { deck in
                DeckDetailView(deck: deck)
            }
            .navigationDestination(for: String.self) { value in
                if value == "settings" {
                    SettingsView()
                }
            }
            .sheet(isPresented: $showingAddDeck) {
                AddEditDeckView()
            }
            .task {
                await scheduleReviewReminderIfNeeded()
            }
        }
    }

    private func dueForReviewCount() -> Int {
        decks.reduce(0) { sum, deck in
            let cards = (deck.cards as? [Card]) ?? []
            return sum + cards.filter { $0.needsReview }.count
        }
    }

    private func scheduleReviewReminderIfNeeded() async {
        guard notificationsEnabled else {
            NotificationService.cancelReviewReminder()
            return
        }
        _ = await NotificationService.requestAuthorization()
        let count = dueForReviewCount()
        NotificationService.scheduleReviewReminder(count: count, hour: reviewReminderHour, minute: reviewReminderMinute)
    }

    private func deleteDecks(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(decks[index])
        }
    }
}

struct DeckRowView: View {
    let deck: Deck

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(deck.name)
                .font(.headline)
            Text("\(deck.sourceLang.uppercased()) → \(deck.targetLang.uppercased())")
                .font(.caption)
                .foregroundStyle(.secondary)
            if let cards = deck.cards as [Card]? {
                Text("\(cards.count) cartas")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    DeckListView()
        .environmentObject(TTSService())
        .modelContainer(for: [Deck.self, Card.self], inMemory: true)
}
