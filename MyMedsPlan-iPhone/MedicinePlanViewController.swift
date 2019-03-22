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
import UICircularProgressRing
import Async
import ALCameraViewController
import AlamofireImage
import CountdownLabel


class MedicinePlanViewController: UIViewController, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var medicineIconImageView: UIImageView!
    @IBOutlet weak var medicineNameLabel: UILabel!
    
    @IBOutlet weak var unitsPerDoseLabel: UILabel!
    @IBOutlet weak var periodicityLabel: UILabel!
    @IBOutlet weak var otherInfoTextView: UITextView!
    
    @IBOutlet weak var counterLabel: CountdownLabel!
    
    @IBOutlet weak var startButton: MMPButton!
    
    @IBOutlet weak var totalDaysLabel: UILabel!
    @IBOutlet weak var pendingDaysLabel: UILabel!
    

    @IBOutlet weak var progressRin: UICircularProgressRing!
    @IBOutlet weak var treatmentTotalDaysTextLabel: UILabel!
    @IBOutlet weak var pendingDaysTextLabel: UILabel!
    
    @IBOutlet weak var statusTextLabel: UILabel!
    @IBOutlet weak var restartPlanContainerView: UIView!
    
    var plan:Plan?
    var notificatinID:String?
    public var comingFromNotification:Bool = false
    public var isTaken:Bool? = false
    
    let takeMessage = NSLocalizedString("takeMessage", comment: "")
    let skipMessage = NSLocalizedString("skipMessage", comment: "")
    let expiredPlanMessage = NSLocalizedString("planExpiredMessage", comment: "")
    let fileManager = FileManager.default
    var croppingParameters: CroppingParameters {
        return CroppingParameters(isEnabled: true, allowResizing: true, allowMoving: true, minimumSize: CGSize(width: 30, height: 30))
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configure()
        
        if comingFromNotification{
            
            guard isTaken != nil else {return}
            if isTaken!{
                showConfirmationPopup(title: NSLocalizedString("TAKEN", comment: ""), message: takeMessage, vc: self, take: true)
            }else{
                showConfirmationPopup(title: NSLocalizedString("SKIPPED", comment: ""), message: skipMessage, vc: self, take: false)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.setProgresRin()
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        if !comingFromNotification{
            _ = navigationController?.popViewController(animated: true)
        }else{
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Configure
    func configure(){
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (granted:Bool, error:Error?) in
            if error != nil {
                print(String(describing: error?.localizedDescription))
            }
            
            MMPManager.sharedInstance.saveGrantedNotificationAccess(completed: granted)
            if granted {
                print("Permission granted")
            } else {
                print("Permission not granted")
                MMPUtils.showPopupWithOK(message: "In order to receive local notifications you need to enable notificiations for My Meds Plan app in you phone settings", vc: self)
            }
        }
        
        medicineNameLabel.text = plan?.medicineName
        periodicityLabel.text = String(describing: (plan?.periodicity)!) + " hrs."
        unitsPerDoseLabel.text = String(describing: (plan?.unitsPerDose)!) + " " + String(describing: (plan?.medicineKind)!)
        totalDaysLabel.text = String(describing: (plan?.durationDays)!)
        
        
        updatePlanStatus()
        updateRemainingDays()
        
        if let additionalInfo = plan?.additionalInfo {
            otherInfoTextView.text = additionalInfo
        }else{
            otherInfoTextView.text = "--"
        }
        
        if let fireDate = plan?.fireDate{
            counterLabel.setCountDownDate(fromDate: Date() as NSDate, targetDate: fireDate as NSDate)
        }
        counterLabel.start()
        updateMedicineImageView()
        startButton.alpha = (plan?.inProgress)! ? 0 : 1
    }
    
    func updateMedicineImageView(){
//        let imagePAth = MMPUtils.getDocumentsDirectory().appendingPathComponent((self.plan?.notificationId)!)
//        let imagePathString = imagePAth.absoluteString + ".png"
        
//        (self.plan?.notificationId)! + ".png")
        
        if let image = MMPUtils.loadImageFromDirectory(fileName: (self.plan?.notificationId)! + ".png") {
            medicineIconImageView.image = image
            medicineIconImageView.setRounded()
        } else {
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
        }
    }
    
    func updateRemainingDays(){
        
        print("Days total: \(String(describing: (plan?.durationDays)!))")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
//        let date = dateFormatter.date(from: "19-07-2017")
        
        if let startDate = plan?.startDate{
            print(String(describing: startDate))
            let numOfDays = startDate.daysBetweenDate(toDate: Date())
            print("Days difference: \(numOfDays)")
            let remainingDays = Int((plan?.durationDays)!) - numOfDays
            if remainingDays >= 0{
                pendingDaysLabel.text = String(describing: remainingDays)
            }else{
                pendingDaysLabel.text = "-"
                showPlanExpiredPopup(title: NSLocalizedString("ATTENTION", comment: ""), message: expiredPlanMessage, vc: self, take: true)
            }
            
//            pendingDaysLabel.text = remainingDays >= 0 ? String(describing: remainingDays) : "-"
        }
    }
    
    
    func updatePlanStatus(){
        let intakes = plan?.event.filter{$0.taken == true}.count
        let progress = (Double((intakes)!) / Double((plan?.totalIntakes)!)) * 100
        guard progress <= 100 else{
            statusTextLabel.text = PlanStatus.StatusFinished
            plan?.status = PlanStatus.StatusFinished
            saveToCoreData()
            return
        }
        
        guard self.plan?.startDate != nil else{
            statusTextLabel.text = PlanStatus.StatusNotStarted
            plan?.status = PlanStatus.StatusNotStarted
            saveToCoreData()
            return
        }
        
        if self.plan?.fireDate == nil{
            statusTextLabel.text = PlanStatus.StatusPaused
            plan?.status = PlanStatus.StatusPaused
        }else{
            statusTextLabel.text = PlanStatus.StatusInProgress
            plan?.status = PlanStatus.StatusInProgress
        }
        saveToCoreData()
//        statusTextLabel.text = self.plan?.fireDate == nil ? PlanStatus.StatusPaused : PlanStatus.StatusInProgress
    }
    
    
    func setProgresRin(){
        print("Total intakes: \(Int((plan?.totalIntakes)!))")
        print("Events count: \((plan?.event.count)!)")
        let intakes = plan?.event.filter{$0.taken == true}.count
        
        var progress = (Double((intakes)!) / Double((plan?.totalIntakes)!)) * 100
        if progress >= 100{
            progress = 100
            UIView.animate(withDuration: 0.5, animations: {
                self.restartPlanContainerView.alpha = 1
            })
        }
        progressRin.startProgress(to: CGFloat(progress), duration: 0.5){
            if progress == 100{
                self.statusTextLabel.text = PlanStatus.StatusFinished
            }
        }
    }
    
    //MARK: - Popups
    func showConfirmationPopup(title:String?, message:String?, vc : UIViewController, take:Bool){
        // Create the dialog
        let image = UIImage(named: "questionMarkBannerBlue")
        let popup = PopupDialog(title: title,
                                message: message,
                                image: image,
                                buttonAlignment: .horizontal,
                                transitionStyle: .zoomIn,
                                tapGestureDismissal: true,
                                panGestureDismissal: true,
                                hideStatusBar: true) {
        }
        
        let buttonOne = DefaultButton(title: NSLocalizedString("RESET", comment: "")) {
            
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
        
        let buttonTwo = CancelButton(title: NSLocalizedString("STOP", comment: "")){
            print("Cancel")
            self.updateCounterRemoveFireDate()
        }
        
        popup.addButtons([buttonTwo, buttonOne])
        
        // Present dialog
        vc.present(popup, animated: true, completion: nil)
        
    }
    
    func showPlanExpiredPopup(title:String?, message:String?, vc : UIViewController, take:Bool){
        // Create the dialog
        let image = UIImage(named: "questionMarkBannerBlue")
        let popup = PopupDialog(title: title,
                                message: message,
                                image: image,
                                buttonAlignment: .vertical,
                                transitionStyle: .bounceUp,
                                tapGestureDismissal: true,
                                panGestureDismissal: true,
                                hideStatusBar: true) {
        }
        
        let buttonOne = DefaultButton(title: NSLocalizedString("RESET", comment: "")) {
            
            self.startOverPlan()
            
        }
        
        let buttonTwo = CancelButton(title: NSLocalizedString("NO", comment: "")){
            print("Cancel")
            //self.updateCounterRemoveFireDate()
        }
        
        popup.addButtons([buttonTwo, buttonOne])
        
        // Present dialog
        vc.present(popup, animated: true, completion: nil)
        
    }
    
    func showOptionsPopup(message:String?, vc : UIViewController){
        // Create the dialog
        let image = UIImage(named: "gearBannerBlue")
        var optionsArray: [PopupDialogButton] = []
        
        let popup = PopupDialog(title: NSLocalizedString(NSLocalizedString("OPTIONS", comment: ""), comment: ""),
                                message: message,
                                image: image,
                                buttonAlignment: .vertical,
                                transitionStyle: .bounceUp,
                                tapGestureDismissal: true,
                                panGestureDismissal: true,
                                hideStatusBar: true) {
        }
        
        let editButton = SolidBlueButton(title: NSLocalizedString(NSLocalizedString("EDIT", comment: ""), comment: "")) {
            self.editPlan()
        }
        optionsArray.append(editButton)
        
        let cancelButton = SolidBlueButton(title: NSLocalizedString(NSLocalizedString("CANCEL", comment: ""), comment: "")){}
        optionsArray.append(cancelButton)
        
        let removeButton = SolidBlueButton(title: NSLocalizedString(NSLocalizedString("REMOVE_IMAGE", comment: ""), comment: "")) {
            self.removeImage()
        }
        if MMPUtils.imageExistsInDirectory(fileName: (self.plan?.notificationId)! + ".png"){
            optionsArray.append(removeButton)
        }
        
        let deleteButton = DestructiveButton(title: NSLocalizedString(NSLocalizedString("DELETE", comment: ""), comment: "")) {
            self.deletePlan()
        }
        optionsArray.append(deleteButton)
        
        popup.addButtons(optionsArray)
        
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
    
    func removeImage(){
        MMPUtils.deleteImageFromDirectory(fileName: (self.plan?.notificationId)! + ".png") { success, error in
            if success{
                self.configure()
            }else{
                debugPrint(error?.localizedDescription)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddFromDetail"{
            let vc = segue.destination as! AddMedicineViewController
            vc.editPlan = sender as? Plan
        }else{
            let vc = segue.destination as! CalendarViewController
            vc.calendarType = .Specific
            vc.singlePlan = sender as? Plan
        }
    }
    
    //MARK: - Buttons
    @IBAction func takeItButtonPressed(_ sender: Any) {
        
        showConfirmationPopup(title: NSLocalizedString("TAKEN", comment: ""), message: takeMessage, vc: self, take: true)
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        
        showConfirmationPopup(title: NSLocalizedString("SKIPPED", comment: ""), message: skipMessage, vc: self, take: false)
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        
        let event = persistentContainer.viewContext.events.create()
        event.eventDate = Date()
        event.plan = self.plan
        event.taken = true
        updateFireDate()
    }
    
    @IBAction func optionsButtonPressed(_ sender: Any) {
        showOptionsPopup(message: NSLocalizedString("Please_select_one_of_the_options_below", comment: ""), vc: self)
    }
    
    @IBAction func startOverButtonPressed(_ sender: Any) {
        startOverPlan()
    }
    
    
    @IBAction func goToCalendarPressed(_ sender: Any) {
        performSegue(withIdentifier: "toCalendarFromPlan", sender: plan)
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        print("camera button pressed")
        let cameraViewController = CameraViewController(croppingParameters: croppingParameters, allowsLibraryAccess: true) { [weak self] image, asset in
            // Do something with your image here.
            if image != nil {
                let fileNameWithExtension = (self?.plan?.notificationId)! + ".png"
                let filename = MMPUtils.getDocumentsDirectory().appendingPathComponent(fileNameWithExtension)
                print("-----> Filename: \(filename.absoluteString)")
                MMPUtils.saveImageInDirectory(image: image!, fileName: fileNameWithExtension)
                
//                if let data = UIImagePNGRepresentation(image!) {
//                    MMPUtils.saveImageDocumentDirectory(imageData: data, fileName: fileNameWithExtension)
////                    try? data.write(to: filename)
//                }
            }
            self?.dismiss(animated: true, completion: nil)
        }
        
        present(cameraViewController, animated: true, completion: nil)
    }
    
    //MARK: - Update Fire Date
    func updateFireDate(){
        
        if self.plan?.startDate == nil {
            self.plan?.startDate = Date()
        }
        
        if self.plan?.endDate == nil {
            if let durationDays = self.plan?.durationDays{
                self.plan?.endDate = Calendar.current.date(byAdding: .day, value: Int(durationDays), to: (self.plan?.startDate!)!)
            }
        }
        
        self.plan?.fireDate = MMPDateUtils.calculateFireDate(hours: (self.plan?.periodicity)!)
        counterLabel.cancel()
        counterLabel.setCountDownDate(fromDate: Date() as NSDate, targetDate: (plan?.fireDate)! as NSDate)
        counterLabel.start()
        self.saveToCoreData()
        
        //let date = Date(timeIntervalSinceNow: 10)
        MMPNotificationCenter.sharedInstance.registerLocalNotification(
            title: "My Meds Plan",
            subtitle: NSLocalizedString("You_need_to_take_your_medicine", comment: "") + ":",
            body: "\((self.plan?.medicineName)!) \(String(describing: (plan?.unitsPerDose)!) + " " + String(describing: (plan?.medicineKind)!))",
            identifier: (self.plan?.notificationId!)!,
            dateTrigger: (self.plan?.fireDate!)! ) //(self.plan?.fireDate!)!
        
        UIView.animate(withDuration: 0.2) {
            self.startButton.alpha = 0
        }
        
        updatePlanStatus()
        Async.main(after: 0.5){
            self.setProgresRin()
            self.updateRemainingDays()
        }
    }
    
    func updateCounterRemoveFireDate(){
        
        self.plan?.fireDate = nil
        self.plan?.inProgress = false
        counterLabel.cancel()
        counterLabel.setCountDownDate(fromDate: Date() as NSDate, targetDate: Date() as NSDate)
        counterLabel.start()
        self.saveToCoreData()
        self.updatePlanStatus()
        
        UIView.animate(withDuration: 0.2) {
            self.startButton.alpha = 1
        }
    }
    
    func restartPlanRemoveEvents(){
        for eachEvent in (self.plan?.event)!{
            eachEvent.delete()
        }
        self.plan?.startDate = nil
        updateCounterRemoveFireDate()
        saveToCoreData()
    }
    
    func startOverPlan(){
        
        progressRin.startProgress(to: CGFloat(0), duration: 0.5)
        UIView.animate(withDuration: 0.5) {
            self.restartPlanContainerView.alpha = 0
        }
        restartPlanRemoveEvents()
        updatePlanStatus()
        updateRemainingDays()
    }
    
    func saveToCoreData(){
        try! persistentContainer.viewContext.save()
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
