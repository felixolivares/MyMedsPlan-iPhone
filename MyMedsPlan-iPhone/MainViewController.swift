//
//  MainViewController.swift
//  MyMedsPlan-iPhone
//
//  Created by Félix Olivares on 04/06/17.
//  Copyright © 2017 Félix Olivares. All rights reserved.
//

import UIKit
import SwipeCellKit
import UserNotifications

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var allPlans:[Plan] = []
    
    var defaultOptions = SwipeTableOptions()
    var isSwipeRightEnabled = true
    var buttonDisplayMode: ButtonDisplayMode = .titleAndImage
    var buttonStyle: ButtonStyle = .backgroundColor
    
    @IBOutlet weak var emptyMessageContainer: UIView!
    let kPlanTableViewCellIdentifier = "PlanTableViewCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configure()
        
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        loadData()
        listNotifications()
    }
    
    func configure(){
        
        /*
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
        */
        if MMPManager._isGrantedNotificationAccess!{
            print("Permissions granted for notifications")
        }
        
        let planTableViewCell = UINib(nibName: "MMPMainTableViewCell", bundle: nil)
        tableView.register(planTableViewCell, forCellReuseIdentifier: kPlanTableViewCellIdentifier)
        tableView.separatorStyle = .none
        
        tableView.allowsSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func loadData(){
        
        allPlans.removeAll()
        let plans = persistentContainer.viewContext.plans
        
        guard plans.count() > 0 else { emptyMessageContainer.isHidden = false; return}
        
        emptyMessageContainer.isHidden = true
        for eachPlan in plans{
            allPlans.append(eachPlan)
            print("\(String(describing: eachPlan.medicineName))")
        }
        tableView.reloadData()
    }
    
    func startButtonPressed(button:UIButton){
        print("Row start button pressed: \(button.tag)")
        
        let indexPath = NSIndexPath.init(row: button.tag, section: 0)
        performSegue(withIdentifier: "toMedicinePlan", sender: allPlans[indexPath.row])
        
        let plan = allPlans[indexPath.row]
        if !plan.inProgress{
            print("plan in progress now")
            plan.fireDate = MMPDateUtils.calculateFireDate(hours: plan.periodicity)
            plan.inProgress = true
            if plan.startDate == nil {
                plan.startDate = Date()
            }
            
            let event = persistentContainer.viewContext.events.create()
            event.eventDate = Date()
            event.plan = plan
            event.taken = true
            
            try! persistentContainer.viewContext.save()
        }
        
        MMPNotificationCenter.sharedInstance.registerLocalNotification(title: "My Meds Plan",
                                                                       subtitle: NSLocalizedString("You_need_to_take_your_medicine", comment: "") + ":",
                                                                       body: "\((plan.medicineName)!) \(String(describing: (plan.unitsPerDose)) + " " + String(describing: (plan.medicineKind)!))",
                                                                       identifier: plan.notificationId!,
                                                                       dateTrigger: plan.fireDate!)
        
//        let cell = self.tableView.cellForRow(at: indexPath as IndexPath) as! MMPMainTableViewCell
//        cell.counterLabel.start()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMedicinePlan"{
            let vc:MedicinePlanViewController = segue.destination as! MedicinePlanViewController
            vc.plan = sender as? Plan
        }
    }
    
    func listNotifications(){
        
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: {requests -> () in
            print("\(requests.count) requests -------")
            for request in requests{
                print(request.identifier)
            }
        })
        UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: {deliveredNotifications -> () in
            print("\(deliveredNotifications.count) Delivered notifications-------")
            for notification in deliveredNotifications{
                print(notification.request.identifier)
            }
        })
    }
    
    func deleteNotification(id:String){
        print("Notification to remove: \(id)")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    // MARK: - Delegate Notifications
    
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allPlans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let indexP = indexPath as IndexPath
        let cell:MMPMainTableViewCell = tableView.dequeueReusableCell(withIdentifier: kPlanTableViewCellIdentifier) as! MMPMainTableViewCell
        cell.delegate = self
        cell.plan = allPlans[indexP.row]
        cell.startButton.tag = indexPath.row
        cell.startButton.addTarget(self, action: #selector(startButtonPressed(button:)), for: .touchUpInside)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        performSegue(withIdentifier: "toMedicinePlan", sender: allPlans[indexPath.row])
    }
}




extension MainViewController: SwipeTableViewCellDelegate{
 
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        if orientation == .right {
            
            let delete = SwipeAction(style: .destructive, title: nil) { action, indexPath in
                let plan = self.allPlans[indexPath.row]
                self.deleteNotification(id: plan.notificationId!)
                persistentContainer.viewContext.plans.delete(plan)
                try! persistentContainer.viewContext.save()
                
                self.allPlans.remove(at: indexPath.row)
                
                self.tableView.beginUpdates()
                action.fulfill(with: .delete)
                self.tableView.endUpdates()
                self.loadData()
            }
            configure(action: delete, with: .trash)
            return [delete]
        }else{
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = orientation == .left ? .selection : .destructive
        options.transitionStyle = defaultOptions.transitionStyle
        
        switch buttonStyle {
        case .backgroundColor:
            options.buttonSpacing = 11
        case .circular:
            options.buttonSpacing = 4
            options.backgroundColor = #colorLiteral(red: 0.9467939734, green: 0.9468161464, blue: 0.9468042254, alpha: 1)
        }
        
        return options
    }
    
    func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
        action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
        action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode)
        
        switch buttonStyle {
        case .backgroundColor:
            action.backgroundColor = descriptor.color
        case .circular:
            action.backgroundColor = .clear
            action.textColor = descriptor.color
            action.font = .systemFont(ofSize: 13)
            action.transitionDelegate = ScaleTransition.default
        }
    }
}

enum ActionDescriptor {
    case read, unread, more, flag, trash
    
    func title(forDisplayMode displayMode: ButtonDisplayMode) -> String? {
        guard displayMode != .imageOnly else { return nil }
        
        switch self {
        case .read: return "Read"
        case .unread: return "Unread"
        case .more: return "More"
        case .flag: return "Flag"
        case .trash: return "Trash"
        }
    }
    
    func image(forStyle style: ButtonStyle, displayMode: ButtonDisplayMode) -> UIImage? {
        guard displayMode != .titleOnly else { return nil }
        
        let name: String
        switch self {
        case .read: name = "Read"
        case .unread: name = "Unread"
        case .more: name = "More"
        case .flag: name = "Flag"
        case .trash: name = "Trash"
        }
        
        return UIImage(named: style == .backgroundColor ? name : name + "-circle")
    }
    
    var color: UIColor {
        switch self {
        case .read, .unread: return #colorLiteral(red: 0, green: 0.4577052593, blue: 1, alpha: 1)
        case .more: return #colorLiteral(red: 0.7803494334, green: 0.7761332393, blue: 0.7967314124, alpha: 1)
        case .flag: return #colorLiteral(red: 1, green: 0.5803921569, blue: 0, alpha: 1)
        case .trash: return #colorLiteral(red: 1, green: 0.2352941176, blue: 0.1882352941, alpha: 1)
        }
    }
}

enum ButtonDisplayMode {
    case titleAndImage, titleOnly, imageOnly
}

enum ButtonStyle {
    case backgroundColor, circular
}
