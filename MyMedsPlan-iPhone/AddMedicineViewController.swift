//
//  AddMedicineViewController.swift
//  MyMedsPlan-iPhone
//
//  Created by Félix Olivares on 04/06/17.
//  Copyright © 2017 Félix Olivares. All rights reserved.
//

import UIKit
import SwiftyPickerPopover

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
    let medicineKindArray:[String] = ["Pills", "Dropplets", "Tablets", "Tea Spoons","Shots"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        _ = navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        
        let context = persistentContainer.viewContext
        
        let plan = context.plans.create()
        
        plan.medicineName = nameTextField.text
        plan.medicineKind = kindTextField.text
        plan.periodicity = Int16(periodicityTextField.text!)!
        plan.unitsPerDose = Int16(unitsTextField.text!)!
        
        do{
            try context.save()
        }catch {}
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField.tag == 2 || textField.tag == 3 || textField.tag == 4{
            
            return false
        }else{
            
            return true
        }
    }
    @IBAction func periodicityTextFieldPressed(_ sender: Any) {
        
        StringPickerPopover(title: "Perdiodicity", choices: periodicityArray)
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
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
