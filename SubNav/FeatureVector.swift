//
//  FeatureVector.swift
//  SubNav
//
//  Created by Florian Deuerlein on 03/08/2016.
//  Copyright © 2016 Florian Deuerlein. All rights reserved.
//

import Foundation
class FeatureVector {
    var timeLine: Array<Array<Double>>
    var timeLineSize:Int
    var featureCount:Int
    
    init(featureCount:Int, timeLineSize:Int) {
        self.featureCount = featureCount
        self.timeLineSize = timeLineSize
        timeLine = Array(count: timeLineSize, repeatedValue: Array(count: featureCount, repeatedValue: 0.0))
    }
    
    func addFeatureVector(vector: Array<Double>) {
        if timeLine.count >=  timeLineSize {
            timeLine.removeAtIndex(0)
        }
        timeLine.append(vector)
    }
    
    func getTimeLine() -> Array<Double> {
        return Array(timeLine.reverse().flatten())
    }
}