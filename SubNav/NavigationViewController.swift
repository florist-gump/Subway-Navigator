//
//  ViewController.swift
//  SubNav
//
//  Created by Florian Deuerlein on 09/07/2016.
//  Copyright © 2016 Florian Deuerlein. All rights reserved.
//

import UIKit

class NavigationViewController: UITableViewController {
    
    @IBOutlet weak var timelineView:UIView?
    
    @IBAction func stop(sender: UIBarButtonItem) {
        let stopAlert = UIAlertController(title: "Stop Navigating", message: "Are you sure you wan't to stop the navigation", preferredStyle: UIAlertControllerStyle.Alert)
        
        stopAlert.addAction(UIAlertAction(title: "Yes", style: .Default, handler: { (action: UIAlertAction!) in
            self.navigationController?.popViewControllerAnimated(true)
        }))
        
        stopAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action: UIAlertAction!) in
            print("Action cancled")
        }))
        
        presentViewController(stopAlert, animated: true, completion: nil)
    }
    
    
    var stops:[String] = []
    var currentStop:Int = 1
    var timeline:TimeLineViewControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "Navigate"
        self.navigationItem.hidesBackButton = true
        timeline = TimeLineViewControl(timeArray: nil, andTimeDescriptionArray: stops as [AnyObject], andCurrentStatus: Int32(currentStop), andFrame: timelineView!.frame)
        timelineView?.addSubview(timeline!)
        
        notifyUser()

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        //currentStop += 1
        //timeline?.updateCurrentStatus(Int32(currentStop))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func notifyUser() {
        // create a corresponding local notification
        let notification = UILocalNotification()
        notification.alertBody = "Please get off at the next stop!"
        notification.alertAction = "open"
        notification.fireDate = NSDate(timeIntervalSinceNow: NSTimeInterval(10.0))
        notification.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }


}

