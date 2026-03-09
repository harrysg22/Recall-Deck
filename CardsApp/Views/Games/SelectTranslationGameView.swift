//
//  SelectTranslationGameView.swift
//  CardsApp
//

import SwiftUI
import SwiftData

struct SelectTranslationGameView: View {
    let cards: [Card]
    let sourceLang: String
    let onResult: (UUID, Bool) -> Void
    let onComplete: () -> Void
    var speakWord: ((String, String?) -> Void)?

    @State private var index = 0
    @State private var options: [String] = []
    @State private var selected: String?
    @State private var revealed = false

    private var current: Card? {
        guard index < cards.count else { return nil }
        return cards[index]
    }

    var body: some View {
        VStack(spacing: 24) {
            if let card = current {
                VStack(spacing: 8) {
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

                Text("Elige la traducción correcta")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { opt in
                        Button {
                            guard !revealed else { return }
                            selected = opt
                            revealed = true
                            let correct = opt == card.translation
                            onResult(card.id, correct)
                        } label: {
                            Text(opt)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(backgroundColor(for: opt))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .disabled(revealed)
                    }
                }

                if revealed {
                    Button("Siguiente") {
                        index += 1
                        if index >= cards.count {
                            onComplete()
                        } else {
                            setupOptions()
                            revealed = false
                            selected = nil
                        }
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
            setupOptions()
        }
    }

    private func setupOptions() {
        guard let card = current else { return }
        var all = cards.map(\.translation).filter { $0 != card.translation }
        all = Array(Set(all)).shuffled()
        let wrong = Array(all.prefix(4))
        options = (wrong + [card.translation]).shuffled()
    }

    private func backgroundColor(for opt: String) -> Color {
        guard revealed, let card = current else { return Color(.secondarySystemBackground) }
        if opt == card.translation { return Color.green.opacity(0.3) }
        if selected == opt { return Color.red.opacity(0.3) }
        return Color(.secondarySystemBackground)
    }
}
