import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleRecyclingReminders(for days: [Int]) {
        // Remove all existing notifications first
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        // Schedule notifications for each selected day
        for day in days {
            // Create notification content
            let content = UNMutableNotificationContent()
            content.title = "Recycling Day Tomorrow"
            content.body = "Don't forget to check your items with SIFT before taking out the recycling!"
            content.sound = .default
            content.badge = 1
            
            // Set up date components for the day before recycling
            var dateComponents = DateComponents()
            // If recycling day is Sunday (0), remind on Saturday (6)
            // Otherwise, remind on (day - 1)
            dateComponents.weekday = day == 0 ? 7 : day // weekday is 1-7, where 1 is Sunday
            dateComponents.hour = 19 // 7 PM
            dateComponents.minute = 0
            
            // Create trigger
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            // Create request
            let request = UNNotificationRequest(
                identifier: "recycling-reminder-\(day)",
                content: content,
                trigger: trigger
            )
            
            // Schedule notification
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateRecyclingDays(_ days: [Int]) {
        scheduleRecyclingReminders(for: days)
    }
    
    func removeAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
