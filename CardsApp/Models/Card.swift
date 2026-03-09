//
//  Card.swift
//  CardsApp
//

import Foundation
import SwiftData

@Model
final class Card {
    var id: UUID
    var word: String
    var translation: String
    var transcription: String
    var example: String
    var imageData: Data?
    var leitnerBox: Int       // 0–8 (8 = learned)
    var nextReviewAt: Date?
    var learnedAt: Date?

    var deck: Deck?

    init(word: String, translation: String, transcription: String = "", example: String = "", imageData: Data? = nil, deck: Deck? = nil) {
        self.id = UUID()
        self.word = word
        self.translation = translation
        self.transcription = transcription
        self.example = example
        self.imageData = imageData
        self.leitnerBox = 0
        self.nextReviewAt = nil
        self.learnedAt = nil
        self.deck = deck
    }

    var isNew: Bool { leitnerBox == 0 }
    var isLearned: Bool { leitnerBox >= 8 }
    var needsReview: Bool {
        guard leitnerBox >= 1, leitnerBox <= 7 else { return false }
        guard let next = nextReviewAt else { return true }
        return next <= Date()
    }
}
