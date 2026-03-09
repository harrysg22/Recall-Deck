//
//  LeitnerEngine.swift
//  CardsApp
//

import Foundation

/// Interval in days for each box (1->2: 1d, 2->3: 2d, 3->4: 3d, 4->5: 7d, 5->6: 14d, 6->7: 30d, 7->8: 90d)
struct LeitnerEngine {
    /// When false (e.g. "Repetir" mode), box and nextReviewAt are not updated on success.
    var applyProgress: Bool = true

    /// On failure, move to this box (0 or 1, configurable in settings).
    var failDownToBox: Int = 1

    private let intervals: [Int] = [0, 1, 2, 3, 7, 14, 30, 90] // index = current box (1..<8), value = days until next

    /// Returns (newBox, newNextReviewAt). Box 8 = learned.
    func afterReview(currentBox: Int, nextReviewAt: Date?, correct: Bool) -> (box: Int, nextReviewAt: Date?) {
        guard correct else {
            let down = min(currentBox, failDownToBox)
            return (down, down == 0 ? nil : Date().addingTimeInterval(86400)) // 1 day if box 1
        }
        if !applyProgress {
            return (currentBox, nextReviewAt)
        }
        let nextBox = min(currentBox + 1, 8)
        if nextBox >= 8 {
            return (8, nil) // learned
        }
        let days = intervals[nextBox]
        let next = Calendar.current.date(byAdding: .day, value: days, to: Date()) ?? Date().addingTimeInterval(TimeInterval(days * 86400))
        return (nextBox, next)
    }

    /// After completing all 5 games in Learn mode: move from box 0 to 1.
    func afterLearnModeComplete() -> (box: Int, nextReviewAt: Date?) {
        let next = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date().addingTimeInterval(86400)
        return (1, next)
    }

    /// When reviewing learned words (box 8) and user fails: back to box 1.
    func afterLearnedReviewFail() -> (box: Int, nextReviewAt: Date?) {
        let next = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date().addingTimeInterval(86400)
        return (1, next)
    }
}
