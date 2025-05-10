//
//  NotificationCenter.swift
//  MyOwnToDoList
//
//  Created by Никита Журавлев on 10.05.2025.
//

import Foundation
import UIKit
import UserNotifications

class NotificationCenter{
    //MARK: - Variables
    static let shared = NotificationCenter()
    
    
    //MARK: - Functions
    private init() {}
    
    // Check and ask for notification permission
    func requestAuthorizationIfNeeded(completion: @escaping (Bool) -> Void){
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings{ settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    //Show system request to allow notifictions
                    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                        DispatchQueue.main.async {
                            completion(granted)
                        }
                    }
                case .denied:
                    completion(false)
                case .authorized, .ephemeral, .provisional:
                    completion(true)
                @unknown default:
                    completion(false)
                }
            }
        }
    }
    
    func scheduleNotification(for task: Task){
        //guard let date = task.date, date > Date() else {return}
        
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = task.title
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.date!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: task.notificationID.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
        print("Notification created with ID: \(task.notificationID.uuidString)")
    }
    
    func removeNotification(for task: Task){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [task.notificationID.uuidString])
        print("Notification deleted with ID: \(task.notificationID.uuidString)")
    }
    
}
