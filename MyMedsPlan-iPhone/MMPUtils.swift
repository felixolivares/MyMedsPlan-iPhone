//
//  MMPUtils.swift
//  MyMedsPlan-iPhone
//
//  Created by Félix Olivares on 05/06/17.
//  Copyright © 2017 Félix Olivares. All rights reserved.
//

import Foundation
import PopupDialog
import Async

struct MedicineType{
    public static let Tablet = "Tablets"
    public static let Shot = "Shots"
    public static let TeaSpoon = "Tea Spoons"
    public static let Pill = "Pills"
    public static let Dropplet = "Dropplets"
}

struct MedicineIcon{
    public static let Dropplet = "droppletsIcon"
    public static let Pill = "pillIcon"
    public static let Shot = "shotIcon"
    public static let Tablet = "tabletsIcon"
    public static let Spoon = "spoonIcon"
}

class MMPUtils{
    
    public static func showPopup(error : NSError, vc : UIViewController){
        // Create the dialog
        let popup = PopupDialog(title: error.localizedFailureReason, message: error.localizedDescription, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {
        }
        
        // Create first button
        let buttonOne = DefaultButton(title: "OK") {
            //            self.label.text = "You canceled the default dialog"
        }
        popup.addButton(buttonOne)
        
        // Present dialog
        vc.present(popup, animated: true, completion: nil)
    }
    
    public static func showPopup(message:String?, vc : UIViewController){
        // Create the dialog
        let popup = PopupDialog(title: "", message: message, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {
            print("Completed")
        }
        
        // Present dialog
        vc.present(popup, animated: true, completion: nil)
        
        Async.main(after: 3){
            popup.dismiss()
        }
    }
    
    public static func showPopupWithOK(message:String?, vc : UIViewController){
        // Create the dialog
        let popup = PopupDialog(title: "", message: message, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {
            print("Completed")
        }
        
        let buttonOne = DefaultButton(title: "OK") {
            //            self.label.text = "You canceled the default dialog"
        }
        popup.addButton(buttonOne)
        
        // Present dialog
        vc.present(popup, animated: true, completion: nil)
        
    }
}
