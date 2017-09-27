//
//  CalendarViewController.swift
//  MyMedsPlan-iPhone
//
//  Created by Félix Olivares on 22/08/17.
//  Copyright © 2017 Félix Olivares. All rights reserved.
//

import UIKit
import JTAppleCalendar
import ChameleonFramework

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var month: UILabel!
    @IBOutlet weak var year: UILabel!
    
    @IBOutlet weak var dotSun: UIView!
    @IBOutlet weak var dotMon: UIView!
    @IBOutlet weak var dotTue: UIView!
    @IBOutlet weak var dotWed: UIView!
    @IBOutlet weak var dotThu: UIView!
    @IBOutlet weak var dotFri: UIView!
    @IBOutlet weak var dotSat: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let formatter = DateFormatter()
    
    let outsideMonthColor = UIColor.init(hexString: "dadada")
    let monthColor = UIColor.init(hexString: "9A9A9A")
    let selectedMonthColor = UIColor.white
    let currentDateSelectedViewColor = UIColor.init(hexString: "F8C473")
    let cal = Calendar(identifier: .gregorian)
    
    var allPlans:[Plan] = []
    var allSelectedPlans:[SelectedPlan] = []
    var allDates:[CalendarDate] = []
    var selectedDates:[Date] = []
    var selectedPlans:[CalendarDate] = []
    
    var calendarType:CalendarType?
    
    var singlePlan:Plan?
    
    let kCalendarTableViewCellIdentifier = "CalendarTableViewCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if calendarType?.rawValue == CalendarType.General.rawValue{
            loadAllPlans()
        }else{
            loadSinglePlan()
        }
        setupCalendarView()
        setupTableView()
        
        calendarView.scrollToDate(Date(), animateScroll: false)
        
        highlightCurrentTreatmentsDay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupCalendarView(){
        
        // Setup calendar spacing
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
        
        // Setup labels
        calendarView.visibleDates{ visibleDates in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        
        //Alpha values for dots
        dotSun.alpha = 0
        dotMon.alpha = 0
        dotTue.alpha = 0
        dotWed.alpha = 0
        dotThu.alpha = 0
        dotFri.alpha = 0
        dotSat.alpha = 0
        
//        calendarView.isUserInteractionEnabled = calendarType?.rawValue == CalendarType.General.rawValue ? true : false
        if calendarType?.rawValue == CalendarType.Specific.rawValue{
            calendarView.allowsMultipleSelection  = true
            calendarView.isRangeSelectionUsed = true
        }
    }
    
    func setupTableView(){
        
        let calendarTableViewCell = UINib(nibName: "MMPCalendarTableViewCell", bundle: nil)
        tableView.register(calendarTableViewCell, forCellReuseIdentifier: kCalendarTableViewCellIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.init(hexString: "F7F7F7")
        
        tableView.allowsSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    //MARK: - Calendar views selection objects
    
    func handleCellTextColor(view:JTAppleCell?, cellState:CellState){
        
        guard let validCell = view as? CustomCell else { return }
        if cellState.isSelected{
            validCell.dateLabel.textColor = selectedMonthColor
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dateLabel.textColor = monthColor
            } else {
                validCell.dateLabel.textColor = outsideMonthColor
            }
        }
    }
    
    func handleCellSelected(view:JTAppleCell?, cellState:CellState){
        
        guard let validCell = view as? CustomCell else { return }
        
        if validCell.isSelected{
            validCell.selectedView.isHidden = false
        } else {
            validCell.selectedView.isHidden = true
        }
    }
    
    func displayScheduledDates(view:JTAppleCell?, cellState:CellState){
        
        guard let validCell = view as? CustomCell else { return }
        
        if let _ = allDates.first(where: {$0.date == cellState.date}){
            
            validCell.dateScheduledDot.isHidden = false
        } else {
            validCell.dateScheduledDot.isHidden = true
        }
    }
    
    func displayTodaySelection(view:JTAppleCell?, cellState:CellState){
        
        guard let validCell = view as? CustomCell else { return }
        
        self.formatter.dateFormat = "yyyy MM dd"
        let cellDate = self.formatter.string(from: cellState.date)
        let todaysDate = self.formatter.string(from: Date())
        
        if cellDate == todaysDate{
            validCell.todaySelectedView.isHidden = false
            validCell.todaySelectedView.layer.borderColor = UIColor.init(hexString: "1a4f69")?.cgColor
            validCell.todaySelectedView.alpha = 0.7
        } else {
            validCell.todaySelectedView.isHidden = true
        }
    }
    
    func displayCurrentTreatmentDays(view:JTAppleCell?, cellState:CellState){
        
        guard let validCell = view as? CustomCell else { return }
        
        if let _ = allDates.first(where: {$0.date == cellState.date}){
            
            switch cellState.selectedPosition() {
            case .full, .left, .right:
                print("Side cell")
                validCell.selectedView.isHidden = false
                validCell.selectedView.backgroundColor = UIColor.yellow // Or you can put what ever you like for your rounded corners, and your stand-alone selected cell
            case .middle:
                print("Middle cell")
                validCell.selectedView.isHidden = false
                validCell.selectedView.backgroundColor = UIColor.blue // Or what ever you want for your dates that land in the middle
            default:
                print("No cell")
                validCell.selectedView.isHidden = true
                validCell.selectedView.backgroundColor = nil // Have no selection when a cell is not selected
            }
        }
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo){
        
        let date = visibleDates.monthDates.first!.date
        
        self.formatter.dateFormat = "yyyy"
        self.year.text = self.formatter.string(from: date)
        
        self.formatter.dateFormat = "MMMM"
        self.month.text = self.formatter.string(from: date)
    }
    
    // MARK: - Day selection
    func daySelection(date:Date){
        
        self.formatter.dateFormat = "E"
        let day = self.formatter.string(from: date)
        hideAndShowDots(hide: false, day: day)
    }
    
    func dayDeselection(date:Date){
        self.formatter.dateFormat = "E"
        let day = self.formatter.string(from: date)
        hideAndShowDots(hide: true, day: day)
    }
    
    func hideAndShowDots(hide:Bool, day:String){
        switch day {
        case "Sun":
            print("Sunday")
            UIView.animate(withDuration: 0.4, animations: { 
                self.dotSun.alpha = hide == true ? 0 : 1
            })
        case "Mon":
            print("Monday")
            UIView.animate(withDuration: 0.4, animations: {
                self.dotMon.alpha = hide == true ? 0 : 1
            })
        case "Tue":
            print("Tuesday")
            UIView.animate(withDuration: 0.4, animations: {
                self.dotTue.alpha = hide == true ? 0 : 1
            })
        case "Wed":
            print("Wednesday")
            UIView.animate(withDuration: 0.4, animations: {
                self.dotWed.alpha = hide == true ? 0 : 1
            })
        case "Thu":
            print("Thursday")
            UIView.animate(withDuration: 0.4, animations: {
                self.dotThu.alpha = hide == true ? 0 : 1
            })
        case "Fri":
            print("Friday")
            UIView.animate(withDuration: 0.4, animations: {
                self.dotFri.alpha = hide == true ? 0 : 1
            })
        default:
            print("Saturday")
            UIView.animate(withDuration: 0.4, animations: {
                self.dotSat.alpha = hide == true ? 0 : 1
            })
        }
    }

    @IBAction func goBack(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func loadAllPlans(){
        
        allPlans.removeAll()
        let plans = persistentContainer.viewContext.plans
        
        guard plans.count() > 0 else { return }
        
        for eachPlan in plans{
            allPlans.append(eachPlan)
            print("\(String(describing: eachPlan.medicineName!))")
        }
        loadAllDates()
    }
    
    func loadSinglePlan(){
        if singlePlan != nil{
            allPlans.append(singlePlan!)
        }
        loadAllDates()
    }
    
    func loadAllDates(){
        
        for eachPlan in allPlans{
            
            if let planStartDate = eachPlan.startDate{
                
                if let planEndDate = eachPlan.endDate{
                    
                    if eachPlan.status == PlanStatus.StatusInProgress || eachPlan.status == PlanStatus.StatusPaused{
                        
                        addDate(date: eachPlan.startDate!, identifier: eachPlan.notificationId)
                        for i in 1...eachPlan.durationDays{
                            
                            let newDate = Calendar.current.date(byAdding: .day, value: Int(i), to: planStartDate)
                            if newDate! <= planEndDate{
                                
                                addDate(date: newDate!, identifier: eachPlan.notificationId)
                            }
                        }
                        
                        print("Start date: \(DateFormatter.localizedString(from: eachPlan.startDate!,dateStyle: .short,timeStyle: .short))")
                        print("End date: \(DateFormatter.localizedString(from: eachPlan.endDate!,dateStyle: .short,timeStyle: .short))")
                        print("How many dates: \(allDates.count)")
                        for eachDate in allDates{
                            print("Each date: \(DateFormatter.localizedString(from: eachDate.date!, dateStyle: .medium, timeStyle: .medium)) - Plans: \(String(describing: eachDate.medicineId?.count))")
                            selectedDates.append(eachDate.date!)
                        }
                    }
                }
            }
        }
    }
    
    func addDate(date:Date, identifier:String?){
        
        let newDate = cal.startOfDay(for: date)
        if identifier != nil{
            
            if var dateFound = allDates.first(where:{$0.date == newDate}){
                
                let index = allDates.index(where: {$0.date == newDate})
                allDates.remove(at: index!)
                dateFound.medicineId?.append(identifier!)
                allDates.append(dateFound)
                
            }else{
                
                var newCalendarDate = CalendarDate()
                newCalendarDate.date = newDate
                if newCalendarDate.medicineId == nil{
                    
                    newCalendarDate.medicineId = []
                }
                newCalendarDate.medicineId?.append(identifier!)
                allDates.append(newCalendarDate)
            }
        }
    }
    
    func highlightCurrentTreatmentsDay(){
        print("highlightn current treamtne days")
        calendarView.selectDates(selectedDates, triggerSelectionDelegate: true, keepSelectionIfMultiSelectionAllowed: false)
        //calendarView.allowsSelection = false
    }
    func populateDataSourceWithPlans(cellState:CellState){
        
        allSelectedPlans.removeAll()
        let midnightDate = cal.startOfDay(for: cellState.date)
        
        let dateSelected = allDates.first{$0.date == midnightDate}
        if dateSelected?.medicineId != nil {
            
            for eachId in (dateSelected?.medicineId)!{
                
                let plan = persistentContainer.viewContext.plans.first{$0.notificationId == eachId}
                if plan != nil{
                    let selectedPlan = SelectedPlan.init(plan: plan, date: midnightDate)
                    allSelectedPlans.append(selectedPlan)
                }
            }
        }
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMedicinePlanFromCalendar" {
            let vc:MedicinePlanViewController = segue.destination as! MedicinePlanViewController
            vc.plan = sender as? Plan
        }
    }
}

extension CalendarViewController: JTAppleCalendarViewDataSource{
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2017 01 01")
        let endDate = formatter.date(from: "2017 12 01")
        
        let parameters = ConfigurationParameters(startDate: startDate!, endDate: endDate!)
        return parameters
    }
}

extension CalendarViewController: JTAppleCalendarViewDelegate{
    
    // Display cell
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CustomCell", for: indexPath) as! CustomCell
        cell.dateLabel.text = cellState.text
        
        if calendarType?.rawValue == CalendarType.General.rawValue{
            
            handleCellSelected(view: cell, cellState: cellState)
            displayScheduledDates(view: cell, cellState: cellState)
        }else{
            displayCurrentTreatmentDays(view: cell, cellState: cellState)
        }
        handleCellTextColor(view: cell, cellState: cellState)
        displayTodaySelection(view: cell, cellState: cellState)
        
        
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        print("Select date method")
        if calendarType?.rawValue == CalendarType.General.rawValue{
            
            //UI
            handleCellSelected(view: cell, cellState: cellState)
            handleCellTextColor(view: cell, cellState: cellState)
            daySelection(date: date)
            
            //Logic
            populateDataSourceWithPlans(cellState: cellState)
            cell?.bounce()
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        
        if calendarType?.rawValue == CalendarType.General.rawValue{
            
            handleCellSelected(view: cell, cellState: cellState)
            handleCellTextColor(view: cell, cellState: cellState)
            dayDeselection(date: date)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        setupViewsOfCalendar(from: visibleDates)
    }
    
//    func calendar
}

extension CalendarViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allSelectedPlans.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kCalendarTableViewCellIdentifier) as! MMPCalendarTableViewCell
        let selectedPlan = allSelectedPlans[indexPath.row].plan
        cell.medicineName.text = selectedPlan?.medicineName
        cell.doseLabel.text = "Dose: \(String(describing: (selectedPlan?.unitsPerDose)!)) \(String(describing: (selectedPlan?.medicineKind)!))"
        
        self.formatter.dateFormat = "E"
        cell.dayLabel.text = self.formatter.string(from: allSelectedPlans[indexPath.row].date!)
        self.formatter.dateFormat = "dd"
        cell.dayNumberLabel.text = self.formatter.string(from: allSelectedPlans[indexPath.row].date!)
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlan = allSelectedPlans[indexPath.row].plan
        performSegue(withIdentifier: "toMedicinePlanFromCalendar", sender: selectedPlan)
    }
}

extension UIView{
    func bounce(){
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 0.1,
                       options: UIViewAnimationOptions.beginFromCurrentState,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: 1, y: 1)
                       })
    }
}
