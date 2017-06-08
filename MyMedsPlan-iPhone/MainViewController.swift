//
//  MainViewController.swift
//  MyMedsPlan-iPhone
//
//  Created by Félix Olivares on 04/06/17.
//  Copyright © 2017 Félix Olivares. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var allPlans:[Plan] = []
    
    let kPlanTableViewCellIdentifier = "PlanTableViewCellIdentifier"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let planTableViewCell = UINib(nibName: "MMPMainTableViewCell", bundle: nil)
        tableView.register(planTableViewCell, forCellReuseIdentifier: kPlanTableViewCellIdentifier)
        tableView.separatorStyle = .none
        loadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        loadData()
    }
    
    func loadData(){
        
        allPlans.removeAll()
        let plans = persistentContainer.viewContext.plans
        for eachPlan in plans{
            allPlans.append(eachPlan)
            print("\(String(describing: eachPlan.medicineName))")
        }
        tableView.reloadData()
    }
    
    func startButtonPressed(button:UIButton){
        print("Row start button pressed: \(button.tag)")
        
        let indexPath = NSIndexPath.init(row: button.tag, section: 0)
        
        let cell = self.tableView.cellForRow(at: indexPath as IndexPath) as! MMPMainTableViewCell
//        cell.counterLabel.start()
    }
    
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
        
        cell.plan = allPlans[indexP.row]
        cell.startButton.tag = indexPath.row
        cell.startButton.addTarget(self, action: #selector(startButtonPressed(button:)), for: .touchUpInside)
//        cell.counterLabel.setCountDownTime(minutes: 60*60)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
}
