//
//  ViewController.swift
//  SubNav
//
//  Created by Florian Deuerlein on 09/07/2016.
//  Copyright © 2016 Florian Deuerlein. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation

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
        locationManager.stopUpdatingLocation()
    }
    
    
    var stops:[String] = []
    var currentStop:Int = 1
    var timeline:TimeLineViewControl?
    
    var motionManager: CMMotionManager?
    var locationManager:CLLocationManager!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "Navigate"
        self.navigationItem.hidesBackButton = true
        timeline = TimeLineViewControl(timeArray: nil, andTimeDescriptionArray: stops as [AnyObject], andCurrentStatus: Int32(currentStop), andFrame: timelineView!.frame)
        timelineView?.addSubview(timeline!)
        
        notifyUser()
        initLocationServices()

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
    
    func initLocationServices() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        switch CLLocationManager.authorizationStatus() {
        case .AuthorizedAlways:
            break
        case .NotDetermined:
            locationManager.requestAlwaysAuthorization()
        case .AuthorizedWhenInUse, .Restricted, .Denied:
            let alertController = UIAlertController(
                title: "Background Location Access Disabled",
                message: "In order to allow location updates in the background, please open app settings and set location access to 'Always'",
                preferredStyle: .Alert)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open Settings", style: .Default) { (action) in
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
            alertController.addAction(openAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        locationManager.allowsBackgroundLocationUpdates = true
        
        locationManager.startUpdatingLocation()
        
        if (motionManager == nil) {
            motionManager = CMMotionManager()
        }
        
        motionManager?.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data: CMDeviceMotion?, error: NSError?) in
            print("x:  \(data!.userAcceleration.x)")
            print("y: \(data!.userAcceleration.y)")
            print("z: \(data!.userAcceleration.z)")
            
        })
    }


}

extension NavigationViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("update")
    }
}

