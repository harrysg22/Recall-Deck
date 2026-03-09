//
//  ReviewModeView.swift
//  CardsApp
//

import SwiftUI
import SwiftData

enum ReviewModeType {
    case review   // due cards, apply progress
    case retry    // any cards, no progress
    case reviewLearned  // box 8, on fail back to 1
}

struct ReviewModeView: View {
    @Bindable var deck: Deck
    let mode: ReviewModeType
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var tts: TTSService

    private var cardsToReview: [Card] {
        let all = deck.cards
        switch mode {
        case .review:
            return all.filter { $0.needsReview }.shuffled()
        case .retry:
            return all.filter { $0.leitnerBox >= 1 && $0.leitnerBox <= 7 }.shuffled()
        case .reviewLearned:
            return all.filter { $0.leitnerBox >= 8 }.shuffled()
        }
    }

    @AppStorage("recallSeconds") private var recallSeconds: Double = 10
    @AppStorage("failDownToBox") private var failDownToBox: Int = 1
    @State private var index = 0
    @State private var currentGame: GameKind = .selectTranslation
    @State private var engine: LeitnerEngine = LeitnerEngine(applyProgress: true)
    @State private var sessionEnded = false

    var body: some View {
        Group {
            if cardsToReview.isEmpty {
                ContentUnavailableView(
                    mode.title,
                    systemImage: "checkmark.circle",
                    description: Text(mode.emptyMessage)
                )
            } else if sessionEnded {
                VStack(spacing: 16) {
                    Text("Repaso completado")
                        .font(.title2)
                    Button("Cerrar") { dismiss() }
                        .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                let card = cardsToReview[index]
                reviewGameView(card: card)
            }
        }
        .navigationTitle(mode.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Salir") { dismiss() }
            }
        }
        .onAppear {
            engine.applyProgress = (mode == .review)
            engine.failDownToBox = failDownToBox
        }
        .onChange(of: failDownToBox) { _, newValue in
            engine.failDownToBox = newValue
        }
    }

    @ViewBuilder
    private func reviewGameView(card: Card) -> some View {
        let cards = [card]
        switch currentGame {
        case .reviewWord:
            ReviewWordGameView(cards: cards, sourceLang: deck.sourceLang, onComplete: { applyAndNext(card: card, correct: true) }, speakWord: { w, ex in tts.speak(word: w, example: ex, language: deck.sourceLang) })
        case .recallWord:
            RecallWordGameView(cards: cards, sourceLang: deck.sourceLang, recallSeconds: recallSeconds, onResult: { _, correct in applyAndNext(card: card, correct: correct) }, onComplete: {}, speakWord: { w, _ in tts.speak(word: w, example: nil, language: deck.sourceLang) })
        case .selectTranslation:
            SelectTranslationGameView(cards: cards, sourceLang: deck.sourceLang, onResult: { _, correct in applyAndNext(card: card, correct: correct) }, onComplete: {}, speakWord: { w, _ in tts.speak(word: w, example: nil, language: deck.sourceLang) })
        case .createPair:
            CreatePairGameView(cards: cards, sourceLang: deck.sourceLang, onResult: { _, correct in
                if cards.first?.id == card.id { applyAndNext(card: card, correct: correct) }
            }, onComplete: {}, speakWord: { w, _ in tts.speak(word: w, example: nil, language: deck.sourceLang) })
        case .typeWord:
            TypeWordGameView(cards: cards, sourceLang: deck.sourceLang, onResult: { _, correct in applyAndNext(card: card, correct: correct) }, onComplete: {}, speakWord: { w, _ in tts.speak(word: w, example: nil, language: deck.sourceLang) })
        }
    }

    private func applyAndNext(card: Card, correct: Bool) {
        let (newBox, nextReview): (Int, Date?)
        if mode == .reviewLearned && !correct {
            (newBox, nextReview) = engine.afterLearnedReviewFail()
        } else {
            (newBox, nextReview) = engine.afterReview(currentBox: card.leitnerBox, nextReviewAt: card.nextReviewAt, correct: correct)
        }
        card.leitnerBox = newBox
        card.nextReviewAt = nextReview
        if newBox >= 8 {
            card.learnedAt = Date()
        }
        index += 1
        if index >= cardsToReview.count {
            sessionEnded = true
        } else {
            currentGame = GameKind.allCases.randomElement() ?? .selectTranslation
        }
    }
}

extension ReviewModeType {
    var title: String {
        switch self {
        case .review: return "Repaso"
        case .retry: return "Repetir"
        case .reviewLearned: return "Revisar aprendidas"
        }
    }
    var emptyMessage: String {
        switch self {
        case .review: return "No hay cartas pendientes de repaso."
        case .retry: return "No hay cartas para repetir."
        case .reviewLearned: return "No hay cartas aprendidas para revisar."
        }
    }
}
