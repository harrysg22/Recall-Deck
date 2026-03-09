//
//  AddEditCardView.swift
//  CardsApp
//

import SwiftUI
import SwiftData

struct AddEditCardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var tts: TTSService

    let deck: Deck
    var card: Card?

    @State private var word = ""
    @State private var translation = ""
    @State private var transcription = ""
    @State private var example = ""
    @State private var isTranslating = false
    @State private var translationError: String?
    @AppStorage("yandexAPIKey") private var yandexAPIKey: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Palabra") {
                    HStack {
                        TextField("Palabra o expresión", text: $word)
                        if !word.isEmpty {
                            Button {
                                tts.speak(word: word, example: example.isEmpty ? nil : example, language: deck.sourceLang)
                            } label: {
                                Image(systemName: "speaker.wave.2.fill")
                            }
                        }
                    }
                    if deck.sourceLang.hasPrefix("zh") {
                        TextField("Pinyin (opcional)", text: $transcription)
                    } else {
                        TextField("Transcripción (opcional)", text: $transcription)
                    }
                }
                Section("Traducción") {
                    TextField("Traducción", text: $translation)
                    if let err = translationError {
                        Text(err)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    if card == nil {
                        Button {
                            Task { await fetchTranslation() }
                        } label: {
                            HStack {
                                if isTranslating {
                                    ProgressView()
                                }
                                Text("Traducir automáticamente")
                            }
                        }
                        .disabled(word.isEmpty || isTranslating || yandexAPIKey.isEmpty)
                    }
                }
                Section("Ejemplo (opcional)") {
                    TextField("Frase de ejemplo", text: $example)
                }
            }
            .navigationTitle(card == nil ? "Nueva carta" : "Editar carta")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                        .disabled(word.trimmingCharacters(in: .whitespaces).isEmpty || translation.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let c = card {
                    word = c.word
                    translation = c.translation
                    transcription = c.transcription
                    example = c.example
                }
            }
        }
    }

    private func fetchTranslation() async {
        translationError = nil
        guard !word.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isTranslating = true
        defer { isTranslating = false }
        let service = YandexDictionaryService()
        do {
            let result = try await service.lookup(word: word.trimmingCharacters(in: .whitespaces), from: deck.sourceLang, to: deck.targetLang, apiKey: yandexAPIKey)
            await MainActor.run {
                translation = result.translation
                if let t = result.transcription, !t.isEmpty { transcription = t }
                if let e = result.example, !e.isEmpty { example = e }
            }
        } catch {
            await MainActor.run {
                translationError = error.localizedDescription
            }
        }
    }

    private func save() {
        let w = word.trimmingCharacters(in: .whitespaces)
        let t = translation.trimmingCharacters(in: .whitespaces)
        guard !w.isEmpty, !t.isEmpty else { return }
        if let c = card {
            c.word = w
            c.translation = t
            c.transcription = transcription.trimmingCharacters(in: .whitespaces)
            c.example = example.trimmingCharacters(in: .whitespaces)
        } else {
            let newCard = Card(word: w, translation: t, transcription: transcription.trimmingCharacters(in: .whitespaces), example: example.trimmingCharacters(in: .whitespaces), deck: deck)
            newCard.deck = deck
            modelContext.insert(newCard)
            deck.cards.append(newCard)
        }
        dismiss()
    }
}

#Preview {
    AddEditCardView(deck: Deck(name: "Chino", sourceLang: "zh", targetLang: "es"))
        .environmentObject(TTSService())
        .modelContainer(for: [Deck.self, Card.self], inMemory: true)
}
