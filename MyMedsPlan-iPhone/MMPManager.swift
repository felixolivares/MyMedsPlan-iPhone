//
//  MMPManager.swift
//  MyMedsPlan-iPhone
//
//  Created by Félix Olivares on 13/06/17.
//  Copyright © 2017 Félix Olivares. All rights reserved.
//

import Foundation

class MMPManager {

    static let sharedInstance = MMPManager()
    
    public static let MMP_IS_GRANTED_NOTIFICATION_ACCESS = "MMP_IS_GRANTED_NOTIFICATION_ACCESS"
    
    public static var _isGrantedNotificationAccess : Bool? = false
    
    private init(){
        
        MMPManager.configure()
    }
    
    private static func configure(){
        
        _isGrantedNotificationAccess = restoreGrantedNotificationAccess()
    }
    
    
    
    //MARK: - Save
    public func saveGrantedNotificationAccess(completed:Bool? = false){
        
        UserDefaults.standard.set(completed, forKey: MMPManager.MMP_IS_GRANTED_NOTIFICATION_ACCESS)
        
        MMPManager._isGrantedNotificationAccess = completed
    }
    
    //MARK: - Restore
    private static func restoreGrantedNotificationAccess() -> Bool {
        
        guard let temp = UserDefaults.standard.object(forKey: MMP_IS_GRANTED_NOTIFICATION_ACCESS) as? Bool else {return false}
        return temp
    }
}
