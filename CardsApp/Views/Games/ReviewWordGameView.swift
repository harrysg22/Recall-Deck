//
//  ReviewWordGameView.swift
//  CardsApp
//

import SwiftUI
import SwiftData

struct ReviewWordGameView: View {
    let cards: [Card]
    let sourceLang: String
    let onComplete: () -> Void
    var speakWord: ((String, String?) -> Void)?

    @State private var index = 0
    @State private var showingBack = false

    private var current: Card? {
        guard index < cards.count else { return nil }
        return cards[index]
    }

    var body: some View {
        VStack(spacing: 24) {
            if let card = current {
                VStack(spacing: 16) {
                    Text(card.word)
                        .font(.title)
                        .multilineTextAlignment(.center)
                    if !card.transcription.isEmpty {
                        Text(card.transcription)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    if let img = card.imageData, let uiImage = UIImage(data: img) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 120)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    Button {
                        speakWord?(card.word, card.example.isEmpty ? nil : card.example)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                            .font(.title2)
                    }
                    .accessibilityLabel("Escuchar pronunciación")
                    .padding(.top, 8)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onTapGesture {
                    withAnimation { showingBack = true }
                }

                if showingBack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Traducción")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(card.translation)
                            .font(.title3)
                        if !card.example.isEmpty {
                            Text(card.example)
                                .font(.footnote)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                HStack {
                    Text("\(index + 1) / \(cards.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button(showingBack ? "Siguiente" : "Mostrar traducción") {
                        if showingBack {
                            advance()
                        } else {
                            withAnimation { showingBack = true }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                Text("Completado")
                    .font(.title2)
                Button("Continuar", action: onComplete)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

    private func advance() {
        if index + 1 >= cards.count {
            onComplete()
        } else {
            index += 1
            showingBack = false
        }
    }
}
