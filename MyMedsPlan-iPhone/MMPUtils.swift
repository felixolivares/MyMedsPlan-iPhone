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


//Structs
struct MedicineType{
    public static let Tablet = NSLocalizedString("Tablets", comment: "")
    public static let Shot = NSLocalizedString("Shots", comment: "")
    public static let TeaSpoon = NSLocalizedString("Tea_Spoons", comment: "")
    public static let Pill = NSLocalizedString("Pills", comment: "")
    public static let Dropplet = NSLocalizedString("Dropplets", comment: "")
}

struct PlanStatus{
    public static let StatusNotStarted = NSLocalizedString("Status_not_started", comment: "")
    public static let StatusInProgress = NSLocalizedString("Status_in_progress", comment: "")
    public static let StatusPaused = NSLocalizedString("Status_paused", comment: "")
    public static let StatusFinished = NSLocalizedString("Status_finished", comment: "")
}

struct MedicineIcon{
    public static let Dropplet = "droppletsIcon"
    public static let Pill = "pillIcon"
    public static let Shot = "shotIcon"
    public static let Tablet = "tabletsIcon"
    public static let Spoon = "spoonIcon"
}

struct CalendarDate{
    var date:Date?
    var medicineId:[String]?
}

struct SelectedPlan{
    var plan:Plan?
    var date:Date?
}

//Enums

enum CalendarType:Int{
    case General
    case Specific
};

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
