//
//  MovingAverage.swift
//  SubNav
//
//  Created by Florian Deuerlein on 03/08/2016.
//  Copyright © 2016 Florian Deuerlein. All rights reserved.
//

import Foundation
class MovingAverage {
    var rawValues: Array<Array<Double>>
    var valueCount = 0
    var windowSize:Int
    var featureCount:Int
    
    init(windowSize: Int, featureCount:Int) {
        self.windowSize = windowSize
        self.featureCount = featureCount
        rawValues = Array<Array<Double>>()
    }
    
    var average: Array<Double> {
        var columnSum:[Double] = [Double](count: featureCount, repeatedValue: 0.0)
        
        for row in rawValues {
            for (index, columnValue) in row.enumerate() {
                columnSum[index] = columnSum[index] + columnValue
            }
        }
        if windowSize > rawValues.count {
            return columnSum.map{$0 / Double(rawValues.count)}
        } else {
            return columnSum.map{$0 / Double(windowSize)}
        }
    }
    
    func addFeatureVector(values: Array<Double>) -> Array<Double> {
        // return the average after a feature vector is added
        let pos = Int(fmodf(Float(valueCount), Float(windowSize)))
        if pos >= rawValues.count {
            rawValues.append(values)
        } else {
            rawValues[pos] = values
        }
        valueCount += 1
        return average
    }
}