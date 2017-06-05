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

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
            layer.borderColor = UIColor.mmpSoftGray.cgColor
            layer.borderWidth = 1.0
        }
    }

}
