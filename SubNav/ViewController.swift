//
//  ViewController.swift
//  SubNav
//
//  Created by Florian Deuerlein on 09/07/2016.
//  Copyright © 2016 Florian Deuerlein. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var timelineView:TimeLineViewControl?
    var stops:[String] = []
    var currentStop:Int32 = 2
    var timeline:TimeLineViewControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "Navigate"
        stops = ["Kelvinbridge","St. George's Cross","Cowcaddens","Buchanan Street","St. Enoch","Brige Street","West Street"]
        currentStop = 3
        timeline = TimeLineViewControl(timeArray: nil, andTimeDescriptionArray: stops as [AnyObject], andCurrentStatus: currentStop, andFrame: timelineView!.frame)
        timelineView?.addSubview(timeline!)

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        currentStop += 1
        timeline?.updateCurrentStatus(currentStop)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

