//
//  GameTypes.swift
//  CardsApp
//

import Foundation

enum GameKind: String, CaseIterable, Identifiable {
    case reviewWord = "Aprender palabra"
    case recallWord = "Recordar / no recordar"
    case selectTranslation = "Elegir traducción"
    case createPair = "Crear pareja"
    case typeWord = "Escribir palabra"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .reviewWord: return "book.fill"
        case .recallWord: return "brain.head.profile"
        case .selectTranslation: return "list.bullet"
        case .createPair: return "arrow.left.arrow.right"
        case .typeWord: return "keyboard"
        }
    }
}

struct GameResultItem: Identifiable {
    let id: UUID
    let cardId: UUID
    let correct: Bool

    init(cardId: UUID, correct: Bool) {
        self.id = UUID()
        self.cardId = cardId
        self.correct = correct
    }
}
