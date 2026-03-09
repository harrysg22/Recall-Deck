//
//  TypeWordGameView.swift
//  CardsApp
//

import SwiftUI
import SwiftData

struct TypeWordGameView: View {
    let cards: [Card]
    let sourceLang: String
    let onResult: (UUID, Bool) -> Void
    let onComplete: () -> Void
    var speakWord: ((String, String?) -> Void)?

    @State private var index = 0
    @State private var input = ""
    @State private var checked = false
    @State private var correct = false

    private var current: Card? {
        guard index < cards.count else { return nil }
        return cards[index]
    }

    var body: some View {
        VStack(spacing: 24) {
            if let card = current {
                VStack(spacing: 8) {
                    Text("Traducción:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(card.translation)
                        .font(.title2)
                    Button {
                        speakWord?(card.word, nil)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title3)
                    }
                }
                .padding()

                TextField("Escribe la palabra", text: $input)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                    .disabled(checked)

                if checked {
                    Text(correct ? "Correcto" : "Correcto: \(card.word)")
                        .foregroundStyle(correct ? .green : .orange)
                    Button("Siguiente") {
                        onResult(card.id, correct)
                        index += 1
                        input = ""
                        checked = false
                        if index >= cards.count {
                            onComplete()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Comprobar") {
                        let raw = input.trimmingCharacters(in: .whitespaces)
                        correct = normalize(raw) == normalize(card.word)
                            || (sourceLang.hasPrefix("zh") && !card.transcription.isEmpty && normalizePinyin(raw) == normalizePinyin(card.transcription))
                        checked = true
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty)
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
    }

    private func normalize(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespaces).lowercased()
            .folding(options: .diacriticInsensitive, locale: .current)
    }

    private func normalizePinyin(_ s: String) -> String {
        s.trimmingCharacters(in: .whitespaces).lowercased()
            .replacingOccurrences(of: " ", with: "")
            .folding(options: .diacriticInsensitive, locale: .current)
    }
}
