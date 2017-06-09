//
//  MMPMainTableViewCell.swift
//  MyMedsPlan-iPhone
//
//  Created by Félix Olivares on 05/06/17.
//  Copyright © 2017 Félix Olivares. All rights reserved.
//

import UIKit
//import CountdownLabel
import SwipeCellKit

class MMPMainTableViewCell: SwipeTableViewCell {

    
    @IBOutlet weak var startButton: MMPButton!
    @IBOutlet weak var dosisLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var medicineImageView: UIImageView!
    @IBOutlet weak var nextIntakeLabel: UILabel!

    
    var plan:Plan? {
        didSet{
            guard plan != nil else {return}
            nameLabel.text = plan?.medicineName
            dosisLabel.text = "Dose: " + String(describing: (plan?.unitsPerDose)!) + " " + String(describing: (plan?.medicineKind)!)
            if (plan?.inProgress)!{
                nextIntakeLabel.text = "Next intake in \(MMPDateUtils.remainingTimeForNextIntake(date:(plan?.fireDate)!))"
            }else{
                nextIntakeLabel.text = "Hit start button"
            }
            if let kind = plan?.medicineKind{
                
                switch kind {
                case MedicineType.Dropplet:
                    medicineImageView.image = UIImage(named: MedicineIcon.Dropplet)
                case MedicineType.Pill:
                    medicineImageView.image = UIImage(named: MedicineIcon.Pill)
                case MedicineType.Shot:
                    medicineImageView.image = UIImage(named: MedicineIcon.Shot)
                case MedicineType.Tablet:
                    medicineImageView.image = UIImage(named: MedicineIcon.Tablet)
                case MedicineType.TeaSpoon:
                    medicineImageView.image = UIImage(named: MedicineIcon.Spoon)
                default:
                    medicineImageView.image = UIImage(named: MedicineIcon.Pill)
                }
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        startButton.setStartButton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
