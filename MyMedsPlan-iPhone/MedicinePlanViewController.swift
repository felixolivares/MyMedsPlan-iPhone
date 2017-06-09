//
//  MedicinePlanViewController.swift
//  MyMedsPlan-iPhone
//
//  Created by Félix Olivares on 08/06/17.
//  Copyright © 2017 Félix Olivares. All rights reserved.
//

import UIKit

class MedicinePlanViewController: UIViewController {
    
    @IBOutlet weak var medicineIconImageView: UIImageView!
    @IBOutlet weak var medicineNameLabel: UILabel!
    
    @IBOutlet weak var unitsPerDoseLabel: UILabel!
    @IBOutlet weak var periodicityLabel: UILabel!
    @IBOutlet weak var otherInfoTextView: UITextView!
    
    @IBOutlet weak var counterLabel: CountdownLabel!
    
    var plan:Plan?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configure()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func goBack(_ sender: Any) {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    func configure(){
        
        medicineNameLabel.text = plan?.medicineName
        periodicityLabel.text = String(describing: (plan?.periodicity)!) + " hrs."
        unitsPerDoseLabel.text = String(describing: (plan?.unitsPerDose)!) + " " + String(describing: (plan?.medicineKind)!)
        if let additionalInfo = plan?.additionalInfo {
            otherInfoTextView.text = additionalInfo
        }else{
            otherInfoTextView.text = "--"
        }
        
        counterLabel.setCountDownDate(fromDate: Date() as NSDate, targetDate: plan?.fireDate as! NSDate)
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
