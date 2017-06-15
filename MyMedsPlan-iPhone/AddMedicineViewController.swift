//
//  AddMedicineViewController.swift
//  MyMedsPlan-iPhone
//
//  Created by Félix Olivares on 04/06/17.
//  Copyright © 2017 Félix Olivares. All rights reserved.
//

import UIKit
import SwiftyPickerPopover
import Async
import PopupDialog

class AddMedicineViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameUnderline: UIView!
    @IBOutlet weak var periodicityTextField: UITextField!
    @IBOutlet weak var periodicityUnderline: UIView!
    @IBOutlet weak var unitsTextField: UITextField!
    @IBOutlet weak var unitsUnderline: UIView!
    @IBOutlet weak var kindTextField: UITextField!
    @IBOutlet weak var kindUnderline: UIView!
    
    @IBOutlet weak var otherInformationTextView: UITextView!
    
    let periodicityArray:[String] = ["1","2","3","4","5","6","7","8","9","10","11","12","24"]
    let unitsPerDoseArray:[String] = ["1","2","3","4","5","10","15","20","30"]
    let medicineKindArray:[String] = [MedicineType.Pill, MedicineType.Dropplet, MedicineType.Tablet, MedicineType.TeaSpoon, MedicineType.Shot]
    
    var editPlan:Plan?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadPlan()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        dismissView()
    }
    
    func dismissView(){
        
        guard editPlan == nil else {self.dismiss(animated: true, completion: {});return}
        _ = navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        
        guard nameTextField.text != "", kindTextField.text != "", periodicityTextField.text != "", unitsTextField.text != "" else {MMPUtils.showPopupWithOK(message: "Please complete all fields", vc: self); return}
        
        
        let context = persistentContainer.viewContext
        var identifier = String()
        
        if editPlan != nil{
            editPlan?.medicineName = nameTextField.text
            editPlan?.medicineKind = kindTextField.text
            editPlan?.periodicity = Int16(periodicityTextField.text!)!
            editPlan?.unitsPerDose = Int16(unitsTextField.text!)!
            editPlan?.startDate = Date()
            //plan.fireDate = MMPDateUtils.calculateFireDate(hours: Int16(periodicityTextField.text!)!)
            editPlan?.additionalInfo = otherInformationTextView.text
            editPlan?.inProgress = false
        }else{
            
            let plan = context.plans.create()
            plan.medicineName = nameTextField.text
            plan.medicineKind = kindTextField.text
            plan.periodicity = Int16(periodicityTextField.text!)!
            plan.unitsPerDose = Int16(unitsTextField.text!)!
            plan.startDate = Date()
            //plan.fireDate = MMPDateUtils.calculateFireDate(hours: Int16(periodicityTextField.text!)!)
            plan.additionalInfo = otherInformationTextView.text
            identifier = "MyMedsPlan." + String(describing:(plan.medicineName)!).trimmingCharacters(in: .whitespaces) + "." + (plan.medicineKind)! + "." + String(describing: (plan.periodicity)) + "." + String(describing: (plan.unitsPerDose))
            plan.notificationId = identifier
        }
        
        do{
            try context.save()
            showPopup(message: "Saved succesfully", vc: self)
        }catch {
            showPopup(message: "There has been an error, please try again.", vc: self)
        }
    }
    
    func loadPlan(){
        
        guard editPlan != nil else {return}
        
        nameTextField.text = editPlan?.medicineName
        otherInformationTextView.text = editPlan?.additionalInfo
        periodicityTextField.text = String(describing: (editPlan?.periodicity)!)
        unitsTextField.text = String(describing: (editPlan?.unitsPerDose)!)
        kindTextField.text = String(describing: (editPlan?.medicineKind)!)
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField.tag == 2 || textField.tag == 3 || textField.tag == 4{
            
            return false
        }else{
            
            return true
        }
    }
    @IBAction func periodicityTextFieldPressed(_ sender: Any) {
        
        StringPickerPopover(title: "Hrs", choices: periodicityArray)
            .setSelectedRow(0)
            .setDoneButton(action: { (popover, selectedRow, selectedString) in
                print("done row \(selectedRow) \(selectedString)")
                self.periodicityTextField.text = selectedString
            })
            .setCancelButton(action: { v in print("cancel")}
            )
            .appear(originView: periodicityUnderline, baseViewController: self)
        
    }
    
    @IBAction func doseTextFieldPressed(_ sender: Any) {
        
        StringPickerPopover(title: "Dose", choices: unitsPerDoseArray)
            .setSelectedRow(0)
            .setDoneButton(action: { (popover, selectedRow, selectedString) in
                self.unitsTextField.text = selectedString
            })
            .setCancelButton(action: { v in print("cancel")}
            )
            .appear(originView: unitsUnderline, baseViewController: self)
    }
    
    @IBAction func kindTextFieldPressed(_ sender: Any) {
        
        StringPickerPopover(title: "Kind", choices: medicineKindArray)
            .setSelectedRow(0)
            .setDoneButton(action: { (popover, selectedRow, selectedString) in
                self.kindTextField.text = selectedString
            })
            .setCancelButton(action: { v in print("cancel")}
            )
            .appear(originView: kindUnderline, baseViewController: self)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag{
        case 1:
            
            if (textField.text?.characters.count)! > 0 {
                nameUnderline.backgroundColor = UIColor.mmpMainBlue
            }else{
                nameUnderline.backgroundColor = UIColor.mmpSoftGray
            }
        case 2:
            if (textField.text?.characters.count)! > 0{
                periodicityUnderline.backgroundColor = UIColor.mmpMainBlue
            }else{
                periodicityUnderline.backgroundColor = UIColor.mmpSoftGray
            }
        default:
            print("no selection")
        }
    }
    
    func showPopup(message:String?, vc : UIViewController){
        // Create the dialog
        let popup = PopupDialog(title: "", message: message, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {
            print("Completed")
            self.dismissView()
        }
        
        // Present dialog
        vc.present(popup, animated: true, completion: nil)
        
        Async.main(after: 2){
            popup.dismiss()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
