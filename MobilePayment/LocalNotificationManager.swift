//
//  LocalNotificationManager.swift
//  MobilePayment
//
//  Created by 이주환 on 2/25/24.
//

import Foundation
import UserNotifications

class LocalNotificationManager: ObservableObject {
    @Published var isGranted: Bool = false
    static let shared = LocalNotificationManager()
    
    struct Alarm {
        var id: String = UUID().uuidString
        var title: String
    }
    
    func requestPermission() -> Void {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .badge, .alert], completionHandler: {
                granted, error in
                if granted == true && error == nil {
                    self.isGranted = true
                } else if let error = error {
                }
            })
    }
    
    func addNotification(title: String, content: String) -> Void {
        let alarm = Alarm(title: title)
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.sound = .default
        notificationContent.body = content
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: alarm.id, content: notificationContent, trigger: trigger)
        UNUserNotificationCenter.current().add(request) {
            error in
            if let error = error {
            }
        }
    }
    
}
