//
//  MMPRoundedCornersView.swift
//  MyMedsPlan-iPhone
//
//  Created by Félix Olivares on 04/06/17.
//  Copyright © 2017 Félix Olivares. All rights reserved.
//

import UIKit

@IBDesignable

class MMPRoundedCornersView: UIView {

    @IBInspectable var cornerGray: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerGray
            layer.masksToBounds = cornerGray > 0
            layer.borderColor = UIColor.mmpSoftGray.cgColor
            layer.borderWidth = 1.0
        }
    }
    
    @IBInspectable var cornerBlue: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerBlue
            layer.masksToBounds = cornerBlue > 0
            layer.borderColor = UIColor.mmpMainBlue.cgColor
            layer.borderWidth = 1.0
        }
    }

}
