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
    var movingAverage: MovingAverage
    var timeLineSize:Int
    var featureCount:Int
    
    init(windowSize: Int, featureCount:Int, timeLineSize:Int) {
        movingAverage = MovingAverage(windowSize: windowSize, featureCount: featureCount)
        self.featureCount = featureCount
        self.timeLineSize = timeLineSize
        timeLine = Array(count: timeLineSize, repeatedValue: Array(count: featureCount, repeatedValue: 0.0))
    }
    
    func addFeatureVector(values: Array<Double>) {
        if timeLine.count <  timeLineSize {
            timeLine.append(movingAverage.addFeatureVector(values))
        } else {
            timeLine.removeAtIndex(0)
            timeLine.append(movingAverage.addFeatureVector(values))
        }
    }
    
    func getTimeLine() -> Array<Double> {
        return Array(timeLine.reverse().flatten())
    }
}