//
//  MedicinePlanViewController.swift
//  MyMedsPlan-iPhone
//
//  Created by Félix Olivares on 08/06/17.
//  Copyright © 2017 Félix Olivares. All rights reserved.
//

import UIKit
import PopupDialog
import UserNotifications

class MedicinePlanViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var medicineIconImageView: UIImageView!
    @IBOutlet weak var medicineNameLabel: UILabel!
    
    @IBOutlet weak var unitsPerDoseLabel: UILabel!
    @IBOutlet weak var periodicityLabel: UILabel!
    @IBOutlet weak var otherInfoTextView: UITextView!
    
    @IBOutlet weak var counterLabel: CountdownLabel!
    @IBOutlet weak var startButton: MMPButton!
    
    var plan:Plan?
    var notificatinID:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        createNotificationID()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configure()
    }
    
    @IBAction func goBack(_ sender: Any) {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    func configure(){
        
        UNUserNotificationCenter.current().delegate = self
        
        medicineNameLabel.text = plan?.medicineName
        periodicityLabel.text = String(describing: (plan?.periodicity)!) + " hrs."
        unitsPerDoseLabel.text = String(describing: (plan?.unitsPerDose)!) + " " + String(describing: (plan?.medicineKind)!)
        if let additionalInfo = plan?.additionalInfo {
            otherInfoTextView.text = additionalInfo
        }else{
            otherInfoTextView.text = "--"
        }
        
        if let fireDate = plan?.fireDate{
            counterLabel.setCountDownDate(fromDate: Date() as NSDate, targetDate: fireDate as NSDate)
        }
        counterLabel.start()
        if let kind = plan?.medicineKind{
            
            switch kind {
            case MedicineType.Dropplet:
                medicineIconImageView.image = UIImage(named: MedicineIcon.Dropplet)
            case MedicineType.Pill:
                medicineIconImageView.image = UIImage(named: MedicineIcon.Pill)
            case MedicineType.Shot:
                medicineIconImageView.image = UIImage(named: MedicineIcon.Shot)
            case MedicineType.Tablet:
                medicineIconImageView.image = UIImage(named: MedicineIcon.Tablet)
            case MedicineType.TeaSpoon:
                medicineIconImageView.image = UIImage(named: MedicineIcon.Spoon)
            default:
                medicineIconImageView.image = UIImage(named: MedicineIcon.Pill)
            }
        }
        
        if !((plan?.inProgress)!){
            startButton.isHidden = false
        }
        
    }

    
    //MARK: - Popups
    func showConfirmationPopup(message:String?, vc : UIViewController, take:Bool){
        // Create the dialog
        let image = UIImage(named: "questionMarkBannerBlue")
        
        let popup = PopupDialog(title: "ATTENTION", message: message, image: image, buttonAlignment: .horizontal, transitionStyle: .zoomIn, gestureDismissal: true) {
            
        }
        
        let buttonOne = DefaultButton(title: "OK") {
            let event = persistentContainer.viewContext.events.create()
            event.eventDate = Date()
            event.plan = self.plan
            if take{
                print("OK - Take")
                event.taken = true
            }else{
                print("OK - Skip")
                event.taken = false
            }
            self.saveToCoreData()
            self.updateFireDate()
        }
        
        let buttonTwo = CancelButton(title: "CANCEL"){
            print("Cancel")
        }
        
        popup.addButtons([buttonTwo, buttonOne])
        
        // Present dialog
        vc.present(popup, animated: true, completion: nil)
        
    }
    
    func showOptionsPopup(message:String?, vc : UIViewController){
        // Create the dialog
        let image = UIImage(named: "gearBannerBlue")
        
        let popup = PopupDialog(title: "OPTIONS", message: message, image: image, buttonAlignment: .vertical, transitionStyle: .bounceUp, gestureDismissal: true) {
            
        }
        
        let editButton = SolidBlueButton(title: "EDIT") {
            self.editPlan()
        }
        
        let deleteButton = DestructiveButton(title: "DELETE") {
            
            self.deletePlan()
        }
        
        let cancelButton = SolidBlueButton(title: "CANCEL"){}
        
        popup.addButtons([editButton, cancelButton, deleteButton])
        
        // Present dialog
        vc.present(popup, animated: true, completion: nil)
        
    }
    
    func deletePlan(){
        
        persistentContainer.viewContext.plans.delete(plan!)
        try! persistentContainer.viewContext.save()
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    func editPlan(){
        
        performSegue(withIdentifier: "toAddFromDetail", sender: plan)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! AddMedicineViewController
        vc.editPlan = sender as? Plan
    }
    
    //MARK: - Buttons
    @IBAction func takeItButtonPressed(_ sender: Any) {
        showConfirmationPopup(message: "After you accept, the countdown will reset and it will be ready for your next intake", vc: self, take: true)
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        showConfirmationPopup(message: "Would you like to reset the countdown to be ready for a next intake? ", vc: self, take: false)
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        updateFireDate()
    }
    
    @IBAction func optionsButtonPressed(_ sender: Any) {
        showOptionsPopup(message: "Please select one of the options below", vc: self)
    }
    
    func updateFireDate(){
        
        self.plan?.fireDate = MMPDateUtils.calculateFireDate(hours: (self.plan?.periodicity)!)
        counterLabel.cancel()
        counterLabel.setCountDownDate(fromDate: Date() as NSDate, targetDate: (plan?.fireDate)! as NSDate)
        counterLabel.start()
        self.saveToCoreData()
    }
    
    func saveToCoreData(){
        try! persistentContainer.viewContext.save()
    }
    
    func createNotificationID(){
        
        let id:String = "MyMedsPlan." + String(describing:(plan?.medicineName)!).trimmingCharacters(in: .whitespaces) + "." + (plan?.medicineKind)! + "." + String(describing: (plan?.periodicity)!) + "." + String(describing: (plan?.unitsPerDose)!)
        print(String(describing: id))
    }
    
    //MARK: Delegates
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
        
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

public final class SolidBlueButton: PopupDialogButton {
    
    override public func setupView() {
        defaultTitleFont      = UIFont.systemFont(ofSize: 14)
        defaultTitleColor     = UIColor(red: 0.25, green: 0.53, blue: 0.91, alpha: 1)
        defaultButtonColor    = UIColor.clear
        defaultSeparatorColor = UIColor.mmpMainAquaAlpha
        super.setupView()
    }
}

public final class RedButton: PopupDialogButton {
    
    override public func setupView() {
        defaultTitleFont      = UIFont.systemFont(ofSize: 14)
        defaultTitleColor     = UIColor.mmpMainBlue
        defaultButtonColor    = UIColor.clear
        defaultSeparatorColor = UIColor.mmpMainAquaAlpha
        super.setupView()
    }
}
