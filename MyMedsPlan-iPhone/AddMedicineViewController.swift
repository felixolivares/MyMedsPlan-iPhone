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
import XLActionController
import GoogleMobileAds

class AddMedicineViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nameUnderline: UIView!
    @IBOutlet weak var periodicityTextField: UITextField!
    @IBOutlet weak var periodicityUnderline: UIView!
    @IBOutlet weak var unitsTextField: UITextField!
    @IBOutlet weak var unitsUnderline: UIView!
    @IBOutlet weak var kindTextField: UITextField!
    @IBOutlet weak var kindUnderline: UIView!
    @IBOutlet weak var durationTextField: UITextField!
    @IBOutlet weak var durationUnderline: UIView!
    
    @IBOutlet weak var bannerAddMedicine: GADBannerView!
    @IBOutlet weak var otherInformationTextView: UITextView!
    
    let periodicityArray:[String] = ["1","2","3","4","5","6","7","8","9","10","11","12","24", "48", "72"]
    let unitsPerDoseArray:[String] = ["1","2","3","4","5","10","15","20","30"]
    let durationDaysArray:[String] = ["1","2","3","4","5","6","7","8","9","10","11","12", "13", "14", "15", "30"]
    let medicineKindArray:[String] = [MedicineType.Pill, MedicineType.Dropplet, MedicineType.Tablet, MedicineType.TeaSpoon, MedicineType.Shot]
    
    var editPlan:Plan?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlan()
        setupAds()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
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
        _ = navigationController?.popViewController(animated: true)
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        
        guard nameTextField.text != "", kindTextField.text != "", periodicityTextField.text != "", unitsTextField.text != "", durationTextField.text != "" else {MMPUtils.showPopupWithOK(message: NSLocalizedString("Please_complete_all_fields", comment: ""), vc: self); return}
        
        
        let context = persistentContainer.viewContext
        var identifier = String()
        
        if editPlan != nil{
            editPlan?.medicineName = nameTextField.text
            editPlan?.medicineKind = kindTextField.text
            editPlan?.periodicity = Int16(periodicityTextField.text!)!
            editPlan?.unitsPerDose = Int16(unitsTextField.text!)!
            if editPlan?.startDate == nil{
                editPlan?.startDate = Date()
            }
            //plan.fireDate = MMPDateUtils.calculateFireDate(hours: Int16(periodicityTextField.text!)!)
            editPlan?.additionalInfo = otherInformationTextView.text
            editPlan?.inProgress = false
            editPlan?.durationDays = Int16(durationTextField.text!)!
            editPlan?.totalIntakes = (Int16(durationTextField.text!)! * 24) / Int16(periodicityTextField.text!)!
            print("Total intakes: \((Int16(durationTextField.text!)! * 24) / Int16(periodicityTextField.text!)!)")
        }else{
            
            let plan = context.plans.create()
            plan.medicineName = nameTextField.text
            plan.medicineKind = kindTextField.text
            plan.periodicity = Int16(periodicityTextField.text!)!
            plan.unitsPerDose = Int16(unitsTextField.text!)!
//            plan.startDate = Date()
            //plan.fireDate = MMPDateUtils.calculateFireDate(hours: Int16(periodicityTextField.text!)!)
            plan.additionalInfo = otherInformationTextView.text
            identifier = "MyMedsPlan." + String(describing:(plan.medicineName)!).trimmingCharacters(in: .whitespaces) + "." + (plan.medicineKind)! + "." + String(describing: (plan.periodicity)) + "." + String(describing: (plan.unitsPerDose))
            plan.notificationId = identifier
            plan.durationDays = Int16(durationTextField.text!)!
            plan.totalIntakes = (Int16(durationTextField.text!)! * 24) / Int16(periodicityTextField.text!)!
            print("Total intakes: \((Int16(durationTextField.text!)! * 24) / Int16(periodicityTextField.text!)!)")
        }
        
        do{
            try context.save()
            showPopup(message: NSLocalizedString("Saved_succesfully", comment: ""), vc: self)
        }catch {
            showPopup(message: NSLocalizedString("There_has_been_an_error", comment: ""), vc: self)
        }
    }
    
    func setupAds(){
        bannerAddMedicine.adSize = kGADAdSizeBanner
        bannerAddMedicine.adUnitID = testingAds ? Constants.Admob.bannerTestId : Constants.Admob.bannerAddMedicine
        bannerAddMedicine.rootViewController = self
        bannerAddMedicine.delegate = self
        bannerAddMedicine.load(AdsManager.shared.getRequest())
    }
    
    func loadPlan(){
        
        guard editPlan != nil else {return}
        
        nameTextField.text = editPlan?.medicineName
        otherInformationTextView.text = editPlan?.additionalInfo
        periodicityTextField.text = String(describing: (editPlan?.periodicity)!)
        unitsTextField.text = String(describing: (editPlan?.unitsPerDose)!)
        kindTextField.text = String(describing: (editPlan?.medicineKind)!)
        durationTextField.text = String(describing: (editPlan?.durationDays)!)
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField.tag == 2 || textField.tag == 3 || textField.tag == 4{
            
            return false
        }else{
            
            return true
        }
    }
    @IBAction func periodicityTextFieldPressed(_ sender: Any) {
        
        StringPickerPopover(title: NSLocalizedString("Hours", comment: ""), choices: periodicityArray)
            .setSelectedRow(0)
            .setDoneButton(action: { (popover, selectedRow, selectedString) in
                print("done row \(selectedRow) \(selectedString)")
                self.periodicityTextField.text = selectedString
            })
            .appear(originView: periodicityUnderline, baseViewController: self)
    }
    
    @IBAction func doseTextFieldPressed(_ sender: Any) {
        
        StringPickerPopover(title: NSLocalizedString("Dose", comment: ""), choices: unitsPerDoseArray)
            .setSelectedRow(0)
            .setDoneButton(action: { (popover, selectedRow, selectedString) in
                self.unitsTextField.text = selectedString
            })
            .appear(originView: unitsUnderline, baseViewController: self)
    }
    
    @IBAction func kindTextFieldPressed(_ sender: Any) {
        
        StringPickerPopover(title: NSLocalizedString("Kind", comment: ""), choices: medicineKindArray)
            .setSelectedRow(0)
            .setDoneButton(action: { (popover, selectedRow, selectedString) in
                self.kindTextField.text = selectedString
            })
            .appear(originView: kindUnderline, baseViewController: self)
    }
    
    @IBAction func durationTextFieldPressed(_ sender: Any) {
        
        StringPickerPopover(title: NSLocalizedString("Days", comment: ""), choices: durationDaysArray)
            .setSelectedRow(0)
            .setDoneButton(action: { (popover, selectedRow, selectedString) in
                self.durationTextField.text = selectedString
            })
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

//MARk: - Admob ads
extension AddMedicineViewController: GADBannerViewDelegate{
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            bannerView.alpha = 1
        })
    }
}
