//
//  LearnModeView.swift
//  CardsApp
//

import SwiftUI
import SwiftData

struct LearnModeView: View {
    @Bindable var deck: Deck
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var tts: TTSService

    private var newCards: [Card] {
        ((deck.cards as? [Card]) ?? []).filter { $0.leitnerBox == 0 }.shuffled()
    }

    @AppStorage("recallSeconds") private var recallSeconds: Double = 10
    @State private var cardIndex = 0
    @State private var gameIndex = 0
    @State private var currentGameResults: [UUID: Bool] = [:]
    private let engine = LeitnerEngine(applyProgress: true)

    private let gameOrder: [GameKind] = [.reviewWord, .recallWord, .selectTranslation, .createPair, .typeWord]

    var body: some View {
        Group {
            if newCards.isEmpty {
                ContentUnavailableView(
                    "No hay palabras nuevas",
                    systemImage: "star",
                    description: Text("Añade cartas al mazo para aprender.")
                )
            } else if cardIndex >= newCards.count {
                VStack(spacing: 16) {
                    Text("Sesión completada")
                        .font(.title2)
                    Button("Cerrar") { dismiss() }
                        .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                let card = newCards[cardIndex]
                let kind = gameOrder[gameIndex]
                gameView(for: kind, card: card)
            }
        }
        .navigationTitle("Modo aprender")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Salir") { dismiss() }
            }
        }
    }

    @ViewBuilder
    private func gameView(for kind: GameKind, card: Card) -> some View {
        let cards = [card]
        switch kind {
        case .reviewWord:
            ReviewWordGameView(cards: cards, sourceLang: deck.sourceLang, onComplete: { learnStepComplete() }, speakWord: { w, ex in tts.speak(word: w, example: ex, language: deck.sourceLang) })
        case .recallWord:
            RecallWordGameView(cards: cards, sourceLang: deck.sourceLang, recallSeconds: recallSeconds, onResult: { id, correct in currentGameResults[id] = correct }, onComplete: { learnStepComplete() }, speakWord: { w, _ in tts.speak(word: w, example: nil, language: deck.sourceLang) })
        case .selectTranslation:
            SelectTranslationGameView(cards: cards, sourceLang: deck.sourceLang, onResult: { id, correct in currentGameResults[id] = correct }, onComplete: { learnStepComplete() }, speakWord: { w, _ in tts.speak(word: w, example: nil, language: deck.sourceLang) })
        case .createPair:
            CreatePairGameView(cards: cards, sourceLang: deck.sourceLang, onResult: { id, correct in currentGameResults[id] = correct }, onComplete: { learnStepComplete() }, speakWord: { w, _ in tts.speak(word: w, example: nil, language: deck.sourceLang) })
        case .typeWord:
            TypeWordGameView(cards: cards, sourceLang: deck.sourceLang, onResult: { id, correct in currentGameResults[id] = correct }, onComplete: { learnStepComplete() }, speakWord: { w, _ in tts.speak(word: w, example: nil, language: deck.sourceLang) })
        }
    }

    private func learnStepComplete() {
        if gameIndex + 1 < gameOrder.count {
            gameIndex += 1
        } else {
            let card = newCards[cardIndex]
            let (box, nextReview) = engine.afterLearnModeComplete()
            card.leitnerBox = box
            card.nextReviewAt = nextReview
            gameIndex = 0
            cardIndex += 1
        }
    }
}
