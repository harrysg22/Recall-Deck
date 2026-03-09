//
//  DeckDetailView.swift
//  CardsApp
//

import SwiftUI
import SwiftData

struct DeckDetailView: View {
    @Bindable var deck: Deck
    @Environment(\.modelContext) private var modelContext
    @State private var showingAddCard = false
    @State private var showingImport = false
    @State private var showingExport = false
    @State private var cardToEdit: Card?
    @State private var exportURL: URL?

    private var deckCards: [Card] {
        (deck.cards as? [Card]) ?? []
    }

    private var newCards: [Card] {
        deckCards.filter { $0.leitnerBox == 0 }
    }

    private var dueForReview: [Card] {
        deckCards.filter { $0.needsReview }
    }

    private var learnedCards: [Card] {
        deckCards.filter { $0.leitnerBox >= 8 }
    }

    var body: some View {
        List {
            Section("Acciones") {
                NavigationLink {
                    LearnModeView(deck: deck)
                } label: {
                    Label("Modo aprender", systemImage: "book.fill")
                }
                .disabled(newCards.isEmpty)

                NavigationLink {
                    ReviewModeView(deck: deck, mode: .review)
                } label: {
                    Label("Repaso", systemImage: "arrow.clockwise.circle.fill")
                }
                .disabled(dueForReview.isEmpty)

                NavigationLink {
                    ReviewModeView(deck: deck, mode: .retry)
                } label: {
                    Label("Repetir", systemImage: "repeat.circle.fill")
                }
                .disabled(deckCards.isEmpty)

                NavigationLink {
                    ReviewModeView(deck: deck, mode: .reviewLearned)
                } label: {
                    Label("Revisar aprendidas", systemImage: "checkmark.circle.fill")
                }
                .disabled(learnedCards.isEmpty)
            }

            Section("Resumen") {
                Label("\(newCards.count) nuevas", systemImage: "star")
                Label("\(dueForReview.count) para repasar", systemImage: "clock")
                Label("\(learnedCards.count) aprendidas", systemImage: "checkmark.circle")
            }

            Section("Cartas") {
                ForEach(deckCards, id: \.id) { card in
                    Button {
                        cardToEdit = card
                    } label: {
                        CardRowView(card: card, sourceLang: deck.sourceLang)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: deleteCards)
            }
        }
        .navigationTitle(deck.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingAddCard = true
                    } label: {
                        Label("Añadir carta", systemImage: "plus")
                    }
                    Button {
                        showingImport = true
                    } label: {
                        Label("Importar CSV", systemImage: "square.and.arrow.down")
                    }
                    Button {
                        exportCSV()
                    } label: {
                        Label("Exportar CSV", systemImage: "square.and.arrow.up")
                    }
                    .disabled(deckCards.isEmpty)
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showingAddCard) {
            AddEditCardView(deck: deck)
        }
        .sheet(isPresented: $showingImport) {
            CSVImportView(deck: deck)
        }
        .sheet(item: $cardToEdit) { card in
            AddEditCardView(deck: deck, card: card)
        }
        .onAppear {
            deck.cards = deck.cards
        }
        .sheet(isPresented: $showingExport) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
    }

    private func exportCSV() {
        let header = "word,translation,transcription,example\n"
        let rows = deckCards.map { card in
            [card.word, card.translation, card.transcription, card.example]
                .map { "\"\($0.replacingOccurrences(of: "\"", with: "\"\""))\"" }
                .joined(separator: ",")
        }
        let csv = header + rows.joined(separator: "\n")
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("\(deck.name)_export.csv")
        try? csv.write(to: tmp, atomically: true, encoding: .utf8)
        exportURL = tmp
        showingExport = true
    }

    private func deleteCards(at offsets: IndexSet) {
        let cards = deckCards
        for index in offsets {
            if index < cards.count {
                modelContext.delete(cards[index])
            }
        }
    }
}

struct CardRowView: View {
    let card: Card
    let sourceLang: String

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(card.word)
                    .font(.headline)
                if !card.translation.isEmpty {
                    Text(card.translation)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                if sourceLang.hasPrefix("zh"), !card.transcription.isEmpty {
                    Text(card.transcription)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                HStack(spacing: 4) {
                    boxBadge(box: card.leitnerBox)
                    if card.learnedAt != nil {
                        Text("Aprendida")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
        .accessibilityHint("Toca para editar")
    }

    @ViewBuilder
    private func boxBadge(box: Int) -> some View {
        if box >= 0, box <= 7 {
            Text("Caja \(box)")
                .font(.caption2)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.blue.opacity(0.2))
                .clipShape(Capsule())
        }
    }
}

extension Card: @retroactive Identifiable { }

#Preview {
    NavigationStack {
        DeckDetailView(deck: Deck(name: "Chino", sourceLang: "zh", targetLang: "es"))
            .environmentObject(TTSService())
            .modelContainer(for: [Deck.self, Card.self], inMemory: true)
    }
}
