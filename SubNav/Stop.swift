//
//  Stop.swift
//  SubNav
//
//  Created by Florian Deuerlein on 17/07/2016.
//  Copyright © 2016 Florian Deuerlein. All rights reserved.
//

import Foundation

class Stop {
    var name:String!
    var stopTime:Float!
    var timeToNextStop:Float!
    
    init(name: String, stopTime:Float, timeToNextStop:Float) {
        self.name = name
        self.stopTime = stopTime
        self.timeToNextStop = timeToNextStop
    }
}