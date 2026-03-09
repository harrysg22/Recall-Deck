//
//  RecallWordGameView.swift
//  CardsApp
//

import SwiftUI
import SwiftData

struct RecallWordGameView: View {
    let cards: [Card]
    let sourceLang: String
    let recallSeconds: Double
    let onResult: (UUID, Bool) -> Void
    let onComplete: () -> Void
    var speakWord: ((String, String?) -> Void)?

    @State private var index = 0
    @State private var timeLeft: Double = 10
    @State private var answered = false
    @State private var timer: Timer?

    private var current: Card? {
        guard index < cards.count else { return nil }
        return cards[index]
    }

    var body: some View {
        VStack(spacing: 24) {
            if let card = current {
                VStack(spacing: 12) {
                    Text(card.word)
                        .font(.title)
                        .multilineTextAlignment(.center)
                    if !card.transcription.isEmpty {
                        Text(card.transcription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Button {
                        speakWord?(card.word, nil)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title3)
                    }
                }
                .padding()

                if !answered {
                    ProgressView(value: timeLeft, total: recallSeconds)
                        .progressViewStyle(.linear)
                    Text("¿Recuerdas la traducción?")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 16) {
                        Button("No recuerdo") {
                            answer(correct: false)
                        }
                        .buttonStyle(.bordered)
                        Button("Recuerdo") {
                            answer(correct: true)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    Text("Traducción: \(card.translation)")
                        .font(.headline)
                        .padding()
                    Button("Siguiente") {
                        nextCard()
                    }
                    .buttonStyle(.borderedProminent)
                }
                Text("\(index + 1) / \(cards.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("Completado")
                    .font(.title2)
                Button("Continuar", action: onComplete)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onAppear {
            timeLeft = recallSeconds
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if timeLeft > 0, !answered {
                    timeLeft -= 1
                } else if timeLeft <= 0, !answered {
                    answer(correct: false)
                }
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func answer(correct: Bool) {
        answered = true
        timer?.invalidate()
        current.map { onResult($0.id, correct) }
    }

    private func nextCard() {
        index += 1
        if index < cards.count {
            timeLeft = recallSeconds
            answered = false
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if timeLeft > 0, !answered {
                    timeLeft -= 1
                } else if timeLeft <= 0, !answered {
                    answer(correct: false)
                }
            }
        } else {
            onComplete()
        }
    }
}
