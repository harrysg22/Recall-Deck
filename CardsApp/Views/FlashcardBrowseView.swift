//
//  FlashcardBrowseView.swift
//  CardsApp
//

import SwiftUI
import SwiftData

/// Modo repaso flashcard: una carta a la vez, solo la palabra visible;
/// botones para revelar pinyin y traducción, escuchar y pasar a la siguiente.
struct FlashcardBrowseView: View {
    @Bindable var deck: Deck
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var tts: TTSService

    @State private var cards: [Card] = []
    @State private var currentIndex = 0
    @State private var showPinyin = false
    @State private var showTranslation = false

    private var currentCard: Card? {
        guard currentIndex >= 0, currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }

    private var isChinese: Bool {
        deck.sourceLang.hasPrefix("zh")
    }

    var body: some View {
        Group {
            if cards.isEmpty {
                ContentUnavailableView(
                    "No hay cartas",
                    systemImage: "rectangle.stack",
                    description: Text("Añade cartas al mazo para usar este modo.")
                )
            } else if let card = currentCard {
                VStack(spacing: 24) {
                    Text("\(currentIndex + 1) / \(cards.count)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(card.word)
                        .font(.system(size: 42, weight: .medium))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)

                    HStack(spacing: 12) {
                        Button {
                            tts.speak(word: card.word, example: card.example.isEmpty ? nil : card.example, language: deck.sourceLang)
                        } label: {
                            Label("Escuchar", systemImage: "speaker.wave.2.fill")
                                .font(.body)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.top, 8)

                    VStack(spacing: 16) {
                        if isChinese && !card.transcription.isEmpty {
                            Button {
                                showPinyin.toggle()
                            } label: {
                                Label(showPinyin ? "Ocultar pinyin" : "Mostrar pinyin", systemImage: showPinyin ? "eye.slash" : "eye")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            if showPinyin {
                                Text(card.transcription)
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 4)
                            }
                        } else if !card.transcription.isEmpty {
                            Button {
                                showPinyin.toggle()
                            } label: {
                                Label(showPinyin ? "Ocultar transcripción" : "Mostrar transcripción", systemImage: showPinyin ? "eye.slash" : "eye")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            if showPinyin {
                                Text(card.transcription)
                                    .font(.title3)
                                    .foregroundStyle(.secondary)
                                    .padding(.top, 4)
                            }
                        }

                        Button {
                            showTranslation.toggle()
                        } label: {
                            Label(showTranslation ? "Ocultar traducción" : "Mostrar traducción", systemImage: showTranslation ? "eye.slash" : "eye")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        if showTranslation {
                            Text(card.translation)
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.top, 4)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                    Spacer()

                    HStack(spacing: 20) {
                        Button {
                            goPrevious()
                        } label: {
                            Label("Anterior", systemImage: "chevron.left")
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(currentIndex <= 0)
                        .buttonStyle(.bordered)

                        Button {
                            goNext()
                        } label: {
                            Label("Siguiente", systemImage: "chevron.right")
                                .frame(maxWidth: .infinity)
                        }
                        .disabled(currentIndex >= cards.count - 1)
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
                }
                .onChange(of: currentIndex) { _, _ in
                    showPinyin = false
                    showTranslation = false
                }
            }
        }
        .navigationTitle("Ver todas las cartas")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if cards.isEmpty {
                cards = ((deck.cards as? [Card]) ?? []).shuffled()
            }
        }
    }

    private func goPrevious() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }

    private func goNext() {
        guard currentIndex < cards.count - 1 else { return }
        currentIndex += 1
    }
}

#Preview {
    NavigationStack {
        FlashcardBrowseView(deck: Deck(name: "Chino", sourceLang: "zh", targetLang: "es"))
            .environmentObject(TTSService())
            .modelContainer(for: [Deck.self, Card.self], inMemory: true)
    }
}
