//
//  MMPNotificationCenter.swift
//  MyMedsPlan-iPhone
//
//  Created by Félix Olivares on 14/06/17.
//  Copyright © 2017 Félix Olivares. All rights reserved.
//

import UIKit
import UserNotifications

class MMPNotificationCenter:NSObject {
    
    static let sharedInstance = MMPNotificationCenter()
    
    private override init() {
        
        MMPNotificationCenter.configure()
    }
    
    private static func configure(){
        
//        UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        print("Notification Delegate set")
    }
    
    public func registerLocalNotification(title:String, subtitle:String,body:String, identifier:String, dateTrigger:Date){
        
        if MMPManager._isGrantedNotificationAccess!{
            
            //Set the content of the notification
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = subtitle
            content.body = body
            content.categoryIdentifier = "actionCategory"
            
            //Set the trigger of the notification -- here a timer.
            let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: dateTrigger)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            //Set the request for the notification from the above
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            //Add the notification to the currnet notification center
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            
            print("Notification posted")
        }
    }
}

