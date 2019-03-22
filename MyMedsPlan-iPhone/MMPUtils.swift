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
        let popup = PopupDialog(title: error.localizedFailureReason,
                                message: error.localizedDescription,
                                buttonAlignment: .horizontal,
                                transitionStyle: .zoomIn,
                                tapGestureDismissal: true,
                                panGestureDismissal: true,
                                hideStatusBar: true) {
        }

//        let popup = PopupDialog(title: error.localizedFailureReason, message: error.localizedDescription, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {
        
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
        let popup = PopupDialog(title: "",
                                message: message,
                                buttonAlignment: .horizontal,
                                transitionStyle: .zoomIn,
                                tapGestureDismissal: true,
                                panGestureDismissal: true,
                                hideStatusBar: true) {
        }
        
        // Present dialog
        vc.present(popup, animated: true, completion: nil)
        
        Async.main(after: 3){
            popup.dismiss()
        }
    }
    
    public static func showPopupWithOK(message:String?, vc : UIViewController){
        // Create the dialog
        let popup = PopupDialog(title: "",
                                message: message,
                                buttonAlignment: .horizontal,
                                transitionStyle: .zoomIn,
                                tapGestureDismissal: true,
                                panGestureDismissal: true,
                                hideStatusBar: true) {
        }
        
        let buttonOne = DefaultButton(title: "OK") {
            //            self.label.text = "You canceled the default dialog"
        }
        popup.addButton(buttonOne)
        
        // Present dialog
        vc.present(popup, animated: true, completion: nil)
    }
    
    //MARK: - File management
    public static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
//    public static func getDirectoryPath() -> String {
//        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
//        let documentsDirectory = paths[0]
//        return documentsDirectory
//    }
//
//    public static func saveImageDocumentDirectory(imageData: Data, fileName: String){
//        let fileManager = FileManager.default
//        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(fileName)
//        print(paths)
//        fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
//    }
//
//    public static func getImageFromFile(imageName: String) -> UIImage?{
//        let fileManager = FileManager.default
//        let imagePAth = (MMPUtils.getDirectoryPath() as NSString).appendingPathComponent(imageName)
//        print("Image file path: \(imagePAth)")
//        if fileManager.fileExists(atPath: (imagePAth)) {
//            let image = UIImage.init(contentsOfFile: imagePAth)
//            let circularImage = image?.af_imageRoundedIntoCircle()
//            return circularImage
//        }else{
//            return nil
//        }
//    }
    
    
    public static func saveImageInDirectory(image: UIImage, fileName: String) {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            try? imageData.write(to: fileURL, options: .atomic)
            return
        }
        print("Error saving image")
    }
    
    public static func loadImageFromDirectory(fileName: String) -> UIImage? {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        do {
            let imageData =  try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {}
        return nil
    }
    
    public static func deleteImageFromDirectory(fileName: String, completionHandler: @escaping (Bool, Error?) -> Void){
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        do {
            let _ = try Data(contentsOf: fileURL)
            try FileManager.default.removeItem(at: fileURL)
            completionHandler(true, nil)
        } catch {
            completionHandler(false, error)
        }
    }
    
    public static func imageExistsInDirectory(fileName: String) -> Bool {
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
        do {
            let _ = try Data(contentsOf: fileURL)
            return true
        } catch {
            return false
        }
    }
}

extension UIImageView {
    
    func setRounded() {
        let radius = self.frame.width / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
