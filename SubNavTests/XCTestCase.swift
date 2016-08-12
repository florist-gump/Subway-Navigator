//
//  SubNavTests.swift
//  SubNavTests
//
//  Created by Florian Deuerlein on 12/08/2016.
//  Copyright © 2016 Florian Deuerlein. All rights reserved.
//

import XCTest
@testable import SubNav

class SubNavTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMovingAverage() { //test if moving avg is working properly
        let movingAverage = MovingAverage(windowSize: 5, featureCount: 1)
        var res = movingAverage.addFeatureVector([1.0])
        XCTAssert(res[0] == 1.0)
        res = movingAverage.addFeatureVector([1.0])
        XCTAssert(res[0] == 1.0)
        res = movingAverage.addFeatureVector([7.0])
        XCTAssert(res[0] == 3.0)
        res = movingAverage.addFeatureVector([3.0])
        XCTAssert(res[0] == 3.0)
        res = movingAverage.addFeatureVector([3.0])
        XCTAssert(res[0] == 3.0)
        res = movingAverage.addFeatureVector([1.0])
        XCTAssert(res[0] == 3.0)
    }
    
    func testTimeLine() { //test if timeline of the feature vector works correclty
        let featureVector = FeatureVector(featureCount: 2, timeLineSize: 3)
        featureVector.addFeatureVector([1.0,1.0])
        XCTAssert(featureVector.getTimeLine() == [1.0,1.0,0.0,0.0,0.0,0.0])
        featureVector.addFeatureVector([2.0,2.0])
        XCTAssert(featureVector.getTimeLine() == [2.0,2.0,1.0,1.0,0.0,0.0])
        featureVector.addFeatureVector([3.0,3.0])
        XCTAssert(featureVector.getTimeLine() == [3.0,3.0,2.0,2.0,1.0,1.0])
        featureVector.addFeatureVector([4.0,4.0])
        XCTAssert(featureVector.getTimeLine() == [4.0,4.0,3.0,3.0,2.0,2.0])
        
    }
    
    func testMLPPrediction() { //test single MLP prediction. 
        let model = ConfiguredMLP()
        let featureVector = FeatureVector(featureCount: 2, timeLineSize: 51)
        featureVector.addFeatureVector([0.1,0.1])
        
        let prediction = model.predict(featureVector.getTimeLine())
        XCTAssert(prediction > 0.0 && prediction < 1.0)
    }
    
    func testLine() { //checks if line loads correclty from csv file
        let line = Line(line: "out")
        let stops = line.stopsBetween("Kelvinhall", destination: "Kelvinbridge")
        XCTAssert(stops.count == 3)
    }
}
