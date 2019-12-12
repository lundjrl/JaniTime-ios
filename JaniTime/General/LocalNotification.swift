//
//  LocalNotifications.swift
//  JaniTime
//
//  Created by Sidharth J Dev on 29/04/19.
//  Copyright © 2019 Sidharth J Dev. All rights reserved.
//

import Foundation
import UIKit
import Foundation
import UserNotifications
class LocalNotification: NSObject, UNUserNotificationCenterDelegate {
    
    class _cancelNotifications {
        func all() {
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.removeAllDeliveredNotifications()
                center.removeAllPendingNotificationRequests()
            }
        }
        func allPending() {
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.removeAllPendingNotificationRequests()
            }
        }
        func allDelivered() {
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.removeAllDeliveredNotifications()
            }
        }
    }
    
    static let cancelNotifications = _cancelNotifications()
    
    struct notificationIdentifiers {
        static let clockedOut = "clocked_out"
        static let willClockOut = "will_clock_out"
    }
    
    class func registerForLocalNotification(on application: UIApplication) {
        if (UIApplication.instancesRespond(to: #selector(UIApplication.registerUserNotificationSettings(_:)))) {
            let notificationCategory: UIMutableUserNotificationCategory = UIMutableUserNotificationCategory()
            notificationCategory.identifier = "NOTIFICATION_CATEGORY"
            
            //registerting for the notification.
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
        }
    }
    
    class func dispatchlocalNotification(with title: String, body: String, userInfo: [AnyHashable: Any]? = nil, timeAfter: TimeInterval, identifier: String) -> UILocalNotification? {
        
        Logger.print("WILL DISPATCH LOCAL NOTIFICATION")
        
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.categoryIdentifier = identifier
            content.userInfo = ["data": "nil"]
            content.sound = UNNotificationSound.default
            JaniTime.vibrateDevice(times: 1)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeAfter, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
            Logger.print("Notification added - \(content.categoryIdentifier)")
        } else {
            Logger.print("Older iOS Version")
        }
        
        return nil
    }
}

extension Date {
    func addedBy(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}
