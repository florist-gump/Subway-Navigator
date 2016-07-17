//
//  Line.swift
//  SubNav
//
//  Created by Florian Deuerlein on 17/07/2016.
//  Copyright © 2016 Florian Deuerlein. All rights reserved.
//

import Foundation
import SwiftCSV

class Line {
    var stops:[Stop]!
    init(line:String) {
        stops = [Stop]()
        changeLine(line)
    }
    func changeLine(line:String) {
        stops.removeAll()
        let fileLocation = NSBundle.mainBundle().pathForResource(line, ofType: "csv")!
        do {
            let stopsCSV = try CSV(name: fileLocation)
            for stopRow in stopsCSV.rows {
                let stopName = stopRow["stop_name"]
                let stopTime = Float(stopRow["stop_time"]!)!
                let stopTimeToNextStop = Float(stopRow["time_to_next_stop"]!)!
                let stop = Stop(name: stopName!, stopTime: stopTime, timeToNextStop: stopTimeToNextStop)
                stops.append(stop)
            }

        } catch {
            print("error reading csv ")
        }
        
    }
    
    func stopsBetween(origin:String, destination:String) -> [Stop] {
        var listOfStops = [Stop]()
        var i = 0
        var indexDest:Int!, indexOrigin:Int!
        for stop in stops {
            if (stop.name == origin) {
                indexOrigin = i
            }
            if (stop.name == destination) {
                indexDest = i
            }
            i = i + 1
        }
        if indexOrigin < indexDest {
            let stopSelection = stops![indexOrigin...indexDest]
            listOfStops = Array(stopSelection)
        } else {
            i = indexOrigin
            var currentStop = stops[i]
            while currentStop.name != stops[indexDest].name {
                listOfStops.append(currentStop)
                if i < stops.count - 1 {
                    i = i + 1
                } else {
                    i = 0
                }
                currentStop = stops[i]
            }
            listOfStops.append(currentStop)
        }
        return listOfStops
    }
    
    func stopNames() -> [String] {
        var stopNames:[String] = [String]()
        for stop in stops {
            stopNames.append(stop.name)
        }
        return stopNames
    }
}
