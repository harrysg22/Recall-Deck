//
//  NotificationService.swift
//  CardsApp
//

import Foundation
import UserNotifications

enum NotificationService {
    static let reviewReminderIdentifier = "cardsapp.review.reminder"

    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func scheduleReviewReminder(count: Int, hour: Int, minute: Int) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reviewReminderIdentifier])
        let content = UNMutableNotificationContent()
        content.title = "Repaso de vocabulario"
        content.body = count > 0 ? "Tienes \(count) palabra\(count == 1 ? "" : "s") para repasar." : "Es hora de repasar tu vocabulario."
        content.sound = .default
        var date = DateComponents()
        date.hour = hour
        date.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: reviewReminderIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    static func cancelReviewReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [reviewReminderIdentifier])
    }
}
