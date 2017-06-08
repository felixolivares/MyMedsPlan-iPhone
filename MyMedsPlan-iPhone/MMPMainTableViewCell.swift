//
//  MMPMainTableViewCell.swift
//  MyMedsPlan-iPhone
//
//  Created by Félix Olivares on 05/06/17.
//  Copyright © 2017 Félix Olivares. All rights reserved.
//

import UIKit
//import CountdownLabel

class MMPMainTableViewCell: UITableViewCell {

    
    @IBOutlet weak var startButton: MMPButton!
    @IBOutlet weak var dosisLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var medicineImageView: UIImageView!

    
    var plan:Plan? {
        didSet{
            guard plan != nil else {return}
            nameLabel.text = plan?.medicineName
            dosisLabel.text = "Take " + String(describing: (plan?.unitsPerDose)!) + " " + String(describing: (plan?.medicineKind)!)
            if let kind = plan?.medicineKind{
                
                switch kind {
                case MedicineType.Dropplet:
                    medicineImageView.image = UIImage(named: "droppletsIcon")
                case MedicineType.Pill:
                    medicineImageView.image = UIImage(named: "pillIcon")
                case MedicineType.Shot:
                    medicineImageView.image = UIImage(named: "shotIcon")
                case MedicineType.Tablet:
                    medicineImageView.image = UIImage(named: "tabletsIcon")
                case MedicineType.TeaSpoon:
                    medicineImageView.image = UIImage(named: "spoonIcon")
                default:
                    medicineImageView.image = UIImage(named: "pillIcon")
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
