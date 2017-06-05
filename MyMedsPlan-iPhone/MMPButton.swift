//
//  MMPButton.swift
//  MyMedsPlan-iPhone
//
//  Created by Félix Olivares on 04/06/17.
//  Copyright © 2017 Félix Olivares. All rights reserved.
//

import UIKit

class MMPButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // set other operations after super.init, if required
        self.layer.cornerRadius = 4;
        //        self.backgroundColor = UIColor.init(red:79/255, green:192/255, blue:232/255, alpha:1);
        self.backgroundColor = UIColor.mmpMainBlue;
        self.tintColor = UIColor.white;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // set other operations after super.init if required
        self.layer.cornerRadius = 4;
        //        self.backgroundColor = UIColor.init(red:79/255, green:192/255, blue:232/255, alpha:1);
        self.backgroundColor = UIColor.mmpMainBlue;
        self.tintColor = UIColor.white;
    }
    
    func setRegisterButton(){
        self.layer.cornerRadius = 4;
        self.layer.borderWidth = 1
        //        self.layer.borderColor = UIColor.init(red:79/255, green:192/255, blue:232/255, alpha:1).cgColor;
        self.layer.borderColor = UIColor.mmpMainBlue.cgColor;
        self.backgroundColor = UIColor.clear
        //        self.tintColor = UIColor.init(red:79/255, green:192/255, blue:232/255, alpha:1);
        self.tintColor = UIColor.mmpMainBlue;
        
    }
    
    func setButtonDisabled(){
        self.layer.cornerRadius = 4;
        self.backgroundColor = UIColor.init(red:170.0/255.0, green:178.0/255.0, blue:188.0/255.0, alpha:1);
        self.tintColor = UIColor.white;
    }

}
