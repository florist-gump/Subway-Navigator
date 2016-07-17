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

class NavigationViewController: UIViewController {
    
    @IBOutlet weak var timelineView:UIView?
    @IBOutlet weak var stopsLeft:UILabel?
    
    
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
    
    
    var stops:[Stop]!
    
    var currentStop:Int = 0
    var timeline:TimeLineViewControl?
    
    var motionManager: CMMotionManager?
    var locationManager:CLLocationManager!

    var darkBlurView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        title = "Navigate"
        self.navigationItem.hidesBackButton = true
        var stopNames:[String] = [String]()
        var stopTimes:[String] = [String]()
        for stop in stops {
            stopNames.append(stop.name)
            stopTimes.append(NSString(format: "%.2f", stop.stopTime+stop.timeToNextStop) as String)
        }
        timeline = TimeLineViewControl(timeArray: stopTimes, andTimeDescriptionArray: stopNames as [AnyObject], andCurrentStatus: Int32(currentStop+1), andFrame: timelineView!.frame)
        timelineView?.addSubview(timeline!)
        stopsLeft?.text = String(stops.count)
        notifyUser()
        initLocationServices()
        //presentPauseScreen()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        currentStop += 1
        updateWith(currentStop)
    }
    
    func updateWith(status:Int) {
        timeline?.updateCurrentStatus(Int32(currentStop+1))
        stopsLeft?.text = String(stops.count - status)
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
    
    func buttonClicked() {
        darkBlurView.removeFromSuperview()
    }
    
    func presentPauseScreen() {
        let darkBlur = UIBlurEffect(style: .Dark)
        darkBlurView = UIVisualEffectView(effect: darkBlur)
        darkBlurView.frame = self.view.bounds
        
        let label = UILabel()
        label.text = "Please start navigation as soon as your on the train"
        label.sizeToFit()
        label.frame.origin = CGPoint(x: 12, y: 12)
        
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        button.setTitle("Start", forState: .Normal)
        button.addTarget(self, action:#selector(self.buttonClicked), forControlEvents: .TouchUpInside)
        
        darkBlurView.contentView.addSubview(button)
        let window = UIApplication.sharedApplication().keyWindow
        window!.addSubview(darkBlurView)

    }


}

extension NavigationViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("update")
    }
}

