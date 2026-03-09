//
//  Deck.swift
//  CardsApp
//

import Foundation
import SwiftData

@Model
final class Deck {
    var id: UUID
    var name: String
    var sourceLang: String  // e.g. "zh", "en", "es"
    var targetLang: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Card.deck)
    var cards: [Card] = []

    init(name: String, sourceLang: String, targetLang: String) {
        self.id = UUID()
        self.name = name
        self.sourceLang = sourceLang
        self.targetLang = targetLang
        self.createdAt = Date()
    }
}
