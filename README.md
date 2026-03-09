# Recall Deck

iOS app for learning vocabulary with flashcards and the Leitner spaced-repetition system. Create decks, add cards (word + translation + optional example), and practice with multiple game modes.

## Features

- **Decks** — Create decks with a source and target language (e.g. Chinese → Spanish, English → French).
- **Leitner system** — Cards move through 8 boxes; correct answers advance them, failures move them back. Box 8 = learned.
- **Learn mode** — Work through new cards (box 0) with five mini-games:
  - **Aprender palabra** — See the word and hear pronunciation.
  - **Recordar / no recordar** — Short recall time, then mark if you remembered.
  - **Elegir traducción** — Pick the right translation.
  - **Crear pareja** — Match word and translation.
  - **Escribir palabra** — Type the word from the translation.
- **Review modes** — Repaso (due cards), Repetir (any cards), Revisar aprendidas (box 8).
- **Text-to-speech** — Hear pronunciation for the deck’s source language (e.g. Chinese, English, Spanish).
- **Edit cards** — Tap any card in the list to edit word, translation, transcription, and example.
- **CSV** — Import and export cards (word, translation, transcription, example).
- **Optional auto-translation** — Yandex Dictionary API key in Settings to translate new words.
- **Notifications** — Daily review reminder at a configurable time.

## Requirements

- iOS 17+
- Xcode 15+ (to build)
- Swift 5

## Building

1. Clone the repo:
   ```bash
   git clone git@github.com:harrysg22/Recall-Deck.git
   cd Recall-Deck
   ```
2. Open `CardsApp.xcodeproj` in Xcode.
3. Select a simulator or device and run (⌘R).

No third-party dependencies; uses SwiftUI, SwiftData, and AVFoundation.

## Project structure

```
Recall Deck/
├── CardsApp.xcodeproj
├── CardsApp/
│   ├── CardsAppApp.swift      # App entry, SwiftData container, TTS
│   ├── Models/
│   │   ├── Deck.swift
│   │   ├── Card.swift
│   │   └── LeitnerEngine.swift
│   ├── Views/
│   │   ├── DeckListView.swift
│   │   ├── DeckDetailView.swift
│   │   ├── AddEditDeckView.swift
│   │   ├── AddEditCardView.swift
│   │   ├── LearnModeView.swift
│   │   ├── ReviewModeView.swift
│   │   ├── SettingsView.swift
│   │   ├── CSVImportView.swift
│   │   ├── ShareSheet.swift
│   │   └── Games/
│   │       ├── GameTypes.swift
│   │       ├── ReviewWordGameView.swift
│   │       ├── RecallWordGameView.swift
│   │       ├── SelectTranslationGameView.swift
│   │       ├── CreatePairGameView.swift
│   │       └── TypeWordGameView.swift
│   ├── Services/
│   │   ├── TTSService.swift
│   │   ├── YandexDictionaryService.swift
│   │   └── NotificationService.swift
│   └── Assets.xcassets
└── README.md
```

## Settings (in app)

- **Juego Recordar** — Recall time (5–60 s) for the “Recordar / no recordar” game.
- **Repaso al fallar** — On wrong answer, move card to box 0 or box 1.
- **Pronunciación** — Speech rate for TTS.
- **Notificaciones** — Toggle and time for daily review reminder.
- **Traducción automática** — Yandex API key (optional).

## License

Private / personal use. No license specified.
