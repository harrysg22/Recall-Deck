//
//  CSVImportView.swift
//  CardsApp
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct CSVImportView: View {
    @Bindable var deck: Deck
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showingPicker = false
    @State private var importedCount = 0
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Importar CSV con columnas: palabra, traducción, transcripción (opcional), ejemplo (opcional)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                if let err = errorMessage {
                    Text(err)
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                if importedCount > 0 {
                    Text("Importadas \(importedCount) cartas")
                        .foregroundStyle(.green)
                }
                Button("Seleccionar archivo CSV") {
                    showingPicker = true
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle("Importar CSV")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") { dismiss() }
                }
            }
            .documentPicker(isPresented: $showingPicker, types: [.commaSeparatedText, .plainText]) { url in
                importCSV(from: url)
            }
        }
    }

    private func importCSV(from url: URL) {
        errorMessage = nil
        importedCount = 0
        let needsStop = url.startAccessingSecurityScopedResource()
        defer { if needsStop { url.stopAccessingSecurityScopedResource() } }
        do {
            let data = try Data(contentsOf: url)
            guard let str = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .isoLatin1) else {
                errorMessage = "Codificación no soportada"
                return
            }
            let lines = str.components(separatedBy: .newlines).filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            var count = 0
            for (i, line) in lines.enumerated() {
                if i == 0 && line.lowercased().hasPrefix("word") { continue }
                let cols = parseCSVLine(line)
                guard cols.count >= 2 else { continue }
                let word = cols[0].trimmingCharacters(in: .whitespaces)
                let translation = cols[1].trimmingCharacters(in: .whitespaces)
                let transcription = cols.count > 2 ? cols[2].trimmingCharacters(in: .whitespaces) : ""
                let example = cols.count > 3 ? cols[3].trimmingCharacters(in: .whitespaces) : ""
                guard !word.isEmpty, !translation.isEmpty else { continue }
                let card = Card(word: word, translation: translation, transcription: transcription, example: example, deck: deck)
                card.deck = deck
                modelContext.insert(card)
                deck.cards.append(card)
                count += 1
            }
            importedCount = count
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var current = ""
        var inQuotes = false
        for ch in line {
            if ch == "\"" {
                inQuotes.toggle()
            } else if (ch == "," && !inQuotes) {
                result.append(current)
                current = ""
            } else {
                current.append(ch)
            }
        }
        result.append(current)
        return result
    }
}

// Document picker wrapper using UIKit
struct DocumentPicker: UIViewControllerRepresentable {
    let types: [UTType]
    let onPick: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onPick: (URL) -> Void
        init(onPick: @escaping (URL) -> Void) { self.onPick = onPick }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onPick(url)
        }
    }
}

extension View {
    func documentPicker(isPresented: Binding<Bool>, types: [UTType], onPick: @escaping (URL) -> Void) -> some View {
        sheet(isPresented: isPresented) {
            DocumentPicker(types: types, onPick: { url in
                onPick(url)
                isPresented.wrappedValue = false
            })
        }
    }
}
