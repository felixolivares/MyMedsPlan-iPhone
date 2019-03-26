//
//  AdsManager.swift
//  MyMedsPlan-iPhone
//
//  Created by Félix Olivares on 3/22/19.
//  Copyright © 2019 Félix Olivares. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AdsManager: NSObject {
    
    static let shared = AdsManager()
    private let adRequest = GADRequest()
    
    public func getRequest() -> GADRequest {
//                adRequest.testDevices = ["83e00fd76a3f30b0f778eff61eb2718a", kGADSimulatorID]
        return adRequest
    }
}
