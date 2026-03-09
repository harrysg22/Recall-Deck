//
//  CreatePairGameView.swift
//  CardsApp
//

import SwiftUI
import SwiftData

private struct WordPair: Hashable {
    let word: String
    let translation: String
}

struct CreatePairGameView: View {
    let cards: [Card]
    let sourceLang: String
    let onResult: (UUID, Bool) -> Void
    let onComplete: () -> Void
    var speakWord: ((String, String?) -> Void)?

    @State private var words: [String] = []
    @State private var translations: [String] = []
    @State private var selectedWord: String?
    @State private var selectedTranslation: String?
    @State private var pairs: [WordPair] = []
    @State private var checked = false
    @State private var allCorrect = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Empareja palabra con traducción")
                .font(.headline)

            if !checked {
                HStack(alignment: .top, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Palabras")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        ForEach(words, id: \.self) { w in
                            Button {
                                if selectedWord == w {
                                    selectedWord = nil
                                } else {
                                    selectedWord = w
                                    tryMatch()
                                }
                            } label: {
                                Text(w)
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(selectedWord == w ? Color.accentColor.opacity(0.3) : Color(.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                        }
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Traducciones")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        ForEach(translations, id: \.self) { t in
                            Button {
                                if selectedTranslation == t {
                                    selectedTranslation = nil
                                } else {
                                    selectedTranslation = t
                                    tryMatch()
                                }
                            } label: {
                                Text(t)
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(selectedTranslation == t ? Color.accentColor.opacity(0.3) : Color(.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                        }
                    }
                }

                Button("Comprobar") {
                    checkPairs()
                }
                .buttonStyle(.borderedProminent)
                .disabled(pairs.count != words.count)
            } else {
                Text(allCorrect ? "¡Correcto!" : "Revisa las parejas")
                    .font(.title2)
                    .foregroundStyle(allCorrect ? .green : .red)
                Button("Continuar") {
                    for card in cards {
                        onResult(card.id, allCorrect)
                    }
                    onComplete()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onAppear {
            words = cards.map(\.word).shuffled()
            translations = cards.map(\.translation).shuffled()
        }
    }

    private func tryMatch() {
        guard let w = selectedWord, let t = selectedTranslation else { return }
        pairs.append(WordPair(word: w, translation: t))
        selectedWord = nil
        selectedTranslation = nil
    }

    private func checkPairs() {
        let correctSet = Set(cards.map { WordPair(word: $0.word, translation: $0.translation) })
        let userSet = Set(pairs)
        allCorrect = userSet == correctSet
        checked = true
    }
}
