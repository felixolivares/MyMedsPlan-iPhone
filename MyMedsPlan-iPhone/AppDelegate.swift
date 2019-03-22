//
//  AppDelegate.swift
//  MyMedsPlan-iPhone
//
//  Created by Félix Olivares on 03/06/17.
//  Copyright © 2017 Félix Olivares. All rights reserved.
//

import UIKit
import AlecrimCoreData
import IQKeyboardManagerSwift
import CoreData
import PopupDialog
import UserNotifications

let persistentContainer = PersistentContainer(name: "MyMedsPlanModel")

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Setup persistent container in order to avoid concurrency
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        //Setup intelligent keyboard
        IQKeyboardManager.shared.enable = true
        
        //Setup popup properties
        setupPopup()
        
        //Remove data from DB
        //removeDataDB()
        
        //Init Managers
        _ = MMPManager.sharedInstance
        _ = MMPNotificationCenter.sharedInstance
        
        //Register rich notifications
        registerForRichNotifications()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func setupPopup(){
        let cancelButtonAppearance = CancelButton.appearance()
        // Default button
        cancelButtonAppearance.titleFont        = UIFont.systemFont(ofSize: 14) //UIFont(name: "Nunito-Bold", size: 14)!
        cancelButtonAppearance.titleColor       = UIColor.mmpMainAqua
        cancelButtonAppearance.buttonColor      = UIColor.clear
        cancelButtonAppearance.separatorColor   = UIColor.mmpMainAquaAlpha
        
        let defaultButtonAppereance = DefaultButton.appearance()
        defaultButtonAppereance.titleFont       = UIFont.systemFont(ofSize: 14)
        defaultButtonAppereance.titleColor      = UIColor.white
        defaultButtonAppereance.buttonColor     = UIColor.mmpMainAqua
        defaultButtonAppereance.separatorColor  = UIColor.mmpMainAquaAlpha
        
        let destructiveButtonAppereance = DestructiveButton.appearance()
        destructiveButtonAppereance.separatorColor = UIColor.mmpMainAquaAlpha
        
        let dialogAppearance = PopupDialogDefaultView.appearance()
        dialogAppearance.backgroundColor        = UIColor.white
        dialogAppearance.titleFont              = UIFont(name: "Nunito-Bold", size: 18)!
        dialogAppearance.messageFont            = UIFont(name: "Nunito-Regular", size: 16)!
        
    }
    
    func removeDataDB(){
        let plans = persistentContainer.viewContext.plans
        plans.deleteAll()
        
        do{
            try persistentContainer.viewContext.save()
        }catch {}
    }
    
    func registerForRichNotifications() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (granted:Bool, error:Error?) in
            if error != nil {
                print(String(describing: error?.localizedDescription))
            }
            if granted {
                print("Permission granted")
            } else {
                print("Permission not granted")
            }
            
            MMPManager.sharedInstance.saveGrantedNotificationAccess(completed: granted)
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        //actions defination
        let action1 = UNNotificationAction(identifier: "action1", title: "Take It", options: [.foreground])
        let action2 = UNNotificationAction(identifier: "action2", title: "Skip", options: [.foreground])
        
        let category = UNNotificationCategory(identifier: "actionCategory", actions: [action1,action2], intentIdentifiers: [], options: [])
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
    }
    @available(iOS 10.0, *)
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        print("GO IN HERE")
        completionHandler([.alert,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case "com.apple.UNNotificationDefaultActionIdentifier":
            
            print("Normal tap")
            goToMedicineDetail(notificationId: response.notification.request.identifier, isTaken: nil)
        case "action1":
            
            print("Taken")
            goToMedicineDetail(notificationId: response.notification.request.identifier, isTaken: true)
        case "action2":
            
            print("Skipped")
            goToMedicineDetail(notificationId: response.notification.request.identifier, isTaken: false)
        default:
            break
        }
        completionHandler()
    }
    
    func goToMedicineDetail(notificationId:String, isTaken:Bool?){
        
        let plan = persistentContainer.viewContext.plans.first{$0.notificationId == notificationId}
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "medicinePlanDetail") as? MedicinePlanViewController {
            if let window = self.window, let rootViewController = window.rootViewController {
                var currentController = rootViewController
                while let presentedController = currentController.presentedViewController {
                    currentController = presentedController
                }
                controller.plan = plan
                controller.comingFromNotification = true
                controller.isTaken = isTaken
                currentController.present(controller, animated: true, completion: nil)
            }
        }
        
    }
    
    /*
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
        print("Notifiation triggered")
    }
    
    */
}

