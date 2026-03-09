//
//  AddEditDeckView.swift
//  CardsApp
//

import SwiftUI
import SwiftData

struct AddEditDeckView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    var existingDeck: Deck?

    @State private var name = ""
    @State private var sourceLang = "zh"
    @State private var targetLang = "es"

    private let languageCodes = ["zh", "en", "es", "fr", "de", "it", "pt", "ja", "ko", "ru", "ar"]

    private var languageName: (String) -> String {
        { code in
            switch code {
            case "zh": return "Chino"
            case "en": return "Inglés"
            case "es": return "Español"
            case "fr": return "Francés"
            case "de": return "Alemán"
            case "it": return "Italiano"
            case "pt": return "Portugués"
            case "ja": return "Japonés"
            case "ko": return "Coreano"
            case "ru": return "Ruso"
            case "ar": return "Árabe"
            default: return code.uppercased()
            }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Mazo") {
                    TextField("Nombre", text: $name)
                }
                Section("Idioma origen") {
                    Picker("Origen", selection: $sourceLang) {
                        ForEach(languageCodes, id: \.self) { code in
                            Text(languageName(code)).tag(code)
                        }
                    }
                    .pickerStyle(.menu)
                }
                Section("Idioma destino") {
                    Picker("Destino", selection: $targetLang) {
                        ForEach(languageCodes, id: \.self) { code in
                            Text(languageName(code)).tag(code)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .navigationTitle(existingDeck == nil ? "Nuevo mazo" : "Editar mazo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { save() }
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let deck = existingDeck {
                    name = deck.name
                    sourceLang = deck.sourceLang
                    targetLang = deck.targetLang
                }
            }
        }
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        if let deck = existingDeck {
            deck.name = trimmed
            deck.sourceLang = sourceLang
            deck.targetLang = targetLang
        } else {
            let deck = Deck(name: trimmed, sourceLang: sourceLang, targetLang: targetLang)
            modelContext.insert(deck)
        }
        dismiss()
    }
}

#Preview {
    AddEditDeckView()
        .modelContainer(for: [Deck.self, Card.self], inMemory: true)
}
