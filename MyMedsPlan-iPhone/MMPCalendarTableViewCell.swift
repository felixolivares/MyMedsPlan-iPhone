//
//  MMPCalendarTableViewCell.swift
//  MyMedsPlan-iPhone
//
//  Created by Félix Olivares on 26/08/17.
//  Copyright © 2017 Félix Olivares. All rights reserved.
//

import UIKit

class MMPCalendarTableViewCell: UITableViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var dayNumberLabel: UILabel!
    @IBOutlet weak var medicineName: UILabel!
    @IBOutlet weak var doseLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
