//
//  ConfiguredMLP.swift
//  SubNav
//
//  Created by Florian Deuerlein on 02/08/2016.
//  Copyright © 2016 Florian Deuerlein. All rights reserved.
//

import Foundation
import MLPNeuralNet

class ConfiguredMLP {
    var model:MLPNeuralNet
    
    init() {
        let config = [3, 2, 1]
        let wts:[Double] = [0.8836501760025713, 8.140083681669564, 9.977493395746547, 6.107642365228793, 0.07049632135115645, -97.68359448401031, -142.11447885813774, -81.58483748940752, 1.2162519445470892, 2.353554008314305, -78.74267900637244]
        
        let weights = NSData(bytes: wts, length: sizeof(Double)*wts.count)
        model = MLPNeuralNet(layerConfig: config, weights: weights, outputMode: MLPClassification)
        model.hiddenActivationFunction = MLPReLU
    }
    
    func predict(input:[Double]) -> Double {
        let vector = NSData(bytes: input, length: sizeof(Double)*input.count)
        var prediction:Double = 0
        let predictionBytes = NSMutableData(length: sizeof(Double))!
        model.predictByFeatureVector(vector, intoPredictionVector: predictionBytes)
        predictionBytes.getBytes(&prediction, length: sizeof(Double))
        return prediction
    }
}