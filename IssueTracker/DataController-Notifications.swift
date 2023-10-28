//
//  DataController-Notifications.swift
//  IssueTracker
//
//  Created by Joel Storr on 28.10.23.
//

import Foundation
import UserNotifications

extension DataController {
    func addReminder(for issue: Issue) async -> Bool {
        do {
            let center = UNUserNotificationCenter.current()
            let settings = await center.notificationSettings()
            
            switch settings.authorizationStatus {
            case .notDetermined:
                let success = try await requestNotification()
                if success {
                    try await placeReminders(for: issue)
                } else {
                    return false
                }
            case .authorized:
                try await placeReminders(for: issue)
            default:
                return false
            }
            return true
        } catch {
            return false
        }
    }
    
    func removeReminders(for issue: Issue) {
        let center = UNUserNotificationCenter.current()
        let id = issue.objectID.uriRepresentation().absoluteString
        center.removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    private func requestNotification() async throws -> Bool {
        // Reqeust access to Notification
        let center = UNUserNotificationCenter.current()
        return try await center.requestAuthorization(options: [.alert, .sound])
    }
    
    private func placeReminders(for issue: Issue) async throws {
        let content = UNMutableNotificationContent()
        content.title = issue.issueTitle
        content.sound = .default
        
        if let issueContent = issue.content {
            content.subtitle = issueContent
        }
        
        // let components = Calendar.current.dateComponents([.hour, .minute], from: issue.issueReminderTime)
        // let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let id = issue.objectID.uriRepresentation().absoluteString
        let reqeust = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        return try await UNUserNotificationCenter.current().add(reqeust)
        
    }
    
}
