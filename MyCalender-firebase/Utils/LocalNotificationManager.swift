

// References:
// 1. https://learnappmaking.com/local-notifications-scheduling-swift/
// 2. https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/1649517-removependingnotificationrequest

import Foundation
import UserNotifications


class LocalNotificationManager {
    var notifications = [Notification]()
    
    // check what local notifications have been scheduled
    func listScheduledNotifications(){
        print("Scheduled notifications list: ")
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {
            notifications in
            for notification in notifications {
                print(notification)
            }
        })
    }
    
    // asking permission to send local notifications
    private func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { granted, error in
            if granted == true && error == nil {
                self.scheduleNotifications()
            }else {
                
            }
        })
    }
    
    // schedule local notifications
    private func scheduleNotifications() {
        for noti in notifications {
            
            let content = UNMutableNotificationContent()
            content.title = noti.title
            content.body = noti.body
            content.sound = .default
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: noti.datetime), repeats: false)
            let request = UNNotificationRequest(identifier: noti.id.uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
                guard error == nil else {return}
                print("Notification scheduled! --- ID = \(noti.id) TIME = \(noti.datetime.getAsFormat(format: "yyyy/MM/dd HH:mm:ss"))")
            })
        }
    }
    
    // checking local notifications permission status
    private func schedule(){
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized:
                self.scheduleNotifications()
            default:
                break
            }
        })
    }
    
    // add notification according to date and time
    func addNotification(notification: Notification){
        
        notifications.append(notification)
        self.schedule()
        listScheduledNotifications()
    }
    
    // delete notification according to id
    func deleteNotification(id: UUID){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id.uuidString])
    }
    
}
