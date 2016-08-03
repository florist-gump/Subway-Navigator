//
//  Model.swift
//  SubNav
//
//  Created by Florian Deuerlein on 03/08/2016.
//  Copyright © 2016 Florian Deuerlein. All rights reserved.
//

import Foundation

protocol StopDectionDelegate: class {
    func stopDetected(sender: Model)
}

class Model {
    weak var delegate:StopDectionDelegate?
    
    let model = ConfiguredMLP()
    let featureVector = FeatureVector(windowSize: 20, featureCount: 2, timeLineSize: 51)
    
    let treshold_moving:Double, treshold_stationary:Double
    var moving = 0 //stationary
    var misclassification_count = 0.0
    var dt:Double
    
    init(dt:Double) {
        self.dt = dt
        (treshold_moving, treshold_stationary) = (5/dt, 2/dt)
    }
    
    func addFeatureVector(vector:[Double]) {
        featureVector.addFeatureVector(vector)
        
        let prediction = model.predict(featureVector.getTimeLine())
        let currSatus = (1-prediction) > 0.5 ? 1 : 0
        
        print(moving)
        if currSatus != moving {
            misclassification_count += 1
            if moving == 1 {
                if misclassification_count > treshold_stationary {
                    moving = 0
                    misclassification_count = 0
                    delegate?.stopDetected(self)
                }
            } else {
                if misclassification_count > treshold_moving {
                    moving = 1
                    misclassification_count = 0
                }
            }
        } else {
            misclassification_count = 0
        }

    }
    
}
