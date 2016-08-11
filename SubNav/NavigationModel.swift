//
//  Model.swift
//  SubNav
//
//  Created by Florian Deuerlein on 03/08/2016.
//  Copyright © 2016 Florian Deuerlein. All rights reserved.
//

import Foundation

protocol NavigationModelDelegate: class {
    func stopDetected(sender: NavigationModel)
    func update(sender: NavigationModel, modelPrediction:Int, movementStatus:Int)
}

class NavigationModel {
    weak var delegate:NavigationModelDelegate?
    
    let model = ConfiguredMLP()
    let featureVector = FeatureVector(featureCount: 2, timeLineSize: 51)
    let movingAverage = MovingAverage(windowSize: 40, featureCount: 6)
    
    let treshold_moving:Double, treshold_stationary:Double
    var movementStatus = 0 //stationary
    var misclassification_count = 0.0
    var dt:Double
    
    init(dt:Double) {
        self.dt = dt
        (treshold_moving, treshold_stationary) = (6/dt, 3/dt)
    }
    
    func update(vector:[Double]) {
        
        let avg = movingAverage.addFeatureVector(vector)
        let acceleration = sqrt(pow(avg[0],2) + pow(avg[1],2) + pow(avg[2],2))
        let rotationRate = sqrt(pow(avg[3],2) + pow(avg[4],2) + pow(avg[5],2))
        
        featureVector.addFeatureVector([acceleration,rotationRate])
        
        let prediction = model.predict(featureVector.getTimeLine())
        let currSatus = (prediction) > 0.5 ? 1 : 0
        
        delegate?.update(self, modelPrediction: currSatus, movementStatus: movementStatus)
        
        if currSatus != movementStatus {
            misclassification_count += 1
            if movementStatus == 1 {
                if misclassification_count > treshold_stationary {
                    movementStatus = 0
                    misclassification_count = 0
                    delegate?.stopDetected(self)
                }
            } else {
                if misclassification_count > treshold_moving {
                    movementStatus = 1
                    misclassification_count = 0
                }
            }
        } else {
            misclassification_count = 0
        }

    }
    
}
