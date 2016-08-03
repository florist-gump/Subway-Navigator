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
import AudioToolbox
import ChameleonFramework
import MLPNeuralNet

class NavigationViewController: UIViewController {
    
    @IBOutlet weak var timelineView:UIScrollView?
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
        motionManager!.stopDeviceMotionUpdates()
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
        initView()
    }
    
    func initView() {
        title = "Navigate"
        self.navigationItem.hidesBackButton = true
        
        stopsLeft?.text = String(stops.count-1)
        var stopNames:[String] = [String]()
        var stopTimes:[String] = [String]()
        let calendar = NSCalendar.currentCalendar()
        var currentTimeOffset:Float = 0.0
        for stop in stops {
            stopNames.append(stop.name)
            let date = calendar.dateByAddingUnit(.Second, value: Int(currentTimeOffset), toDate: NSDate(), options: [])
            let components = calendar.components([ .Hour, .Minute, .Second], fromDate: date!)
            stopTimes.append(String(format: "%02d:%02d", components.hour, components.minute))
            currentTimeOffset = currentTimeOffset + stop.stopTime + stop.timeToNextStop
        }
        let frame = CGRectMake(0, 0, self.view.frame.size.width - 30, 200)
        timeline = TimeLineViewControl(timeArray: stopTimes, andTimeDescriptionArray: stopNames as [AnyObject], andCurrentStatus: Int32(currentStop+1), andFrame: frame)
        
        timelineView!.contentSize = CGSize(width: self.view.frame.size.width - 40, height: timeline!.viewheight+20)        
        timelineView!.showsVerticalScrollIndicator = false
        timelineView!.showsHorizontalScrollIndicator = false
        timelineView?.addSubview(timeline!)
        
        //presentPauseScreen()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        currentStop += 1
        updateWith(currentStop)
    }
    
    func updateWith(status:Int) {
        if status < stops.count {
            timeline?.updateCurrentStatus(Int32(currentStop+1))
            stopsLeft?.text = String(stops.count - status - 1)
            if status == stops.count - 1 {
                notifyUser("Please get off at the next stop!", message: "Your stop is coming up.")
                locationManager.stopUpdatingLocation()
                motionManager!.stopDeviceMotionUpdates()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func notifyUser(title: String, message: String) {
        let state = UIApplication.sharedApplication().applicationState
        if (state == UIApplicationState.Background || state == UIApplicationState.Inactive)
        {
            let notification = UILocalNotification()
            notification.alertBody = title
            notification.alertAction = "open"
            notification.fireDate = NSDate(timeIntervalSinceNow: NSTimeInterval(10.0))
            notification.soundName = UILocalNotificationDefaultSoundName
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        } else {
            let getOffAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            
            getOffAlert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
            
            presentViewController(getOffAlert, animated: true, completion: nil)
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
       
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
        motionManager?.deviceMotionUpdateInterval = 0.01
        
        let model = ConfiguredMLP()
                        
        motionManager?.startDeviceMotionUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: { (data: CMDeviceMotion?, error: NSError?) in            
            
            let x = data!.userAcceleration.x
            let y = data!.userAcceleration.y
            let z = data!.userAcceleration.z
            let inputVector:[Double] = [pow(x,2),pow(y,2),pow(z,2)]
            
            let prediction = model.predict(inputVector)
            print(prediction)
            
            // update UI
            NSOperationQueue.mainQueue().addOperationWithBlock {
                if (prediction > 0.5) {
                    self.currentStop += 1
                    self.updateWith(self.currentStop)
                }
            }
            
        })
    }
    
    func removePauseView() {
        darkBlurView.removeFromSuperview()
        initLocationServices()
    }
    
    func presentPauseScreen() {
        let window = UIApplication.sharedApplication().keyWindow
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        darkBlurView = UIVisualEffectView(effect: blurEffect)
        darkBlurView.frame = window!.bounds
        window!.addSubview(darkBlurView)
        
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = view.bounds

        let title = UILabel()
        title.text = "Navigation Paused"
        title.font = UIFont.systemFontOfSize(25.0)
        title.sizeToFit()
        title.translatesAutoresizingMaskIntoConstraints = false
        
        let description = UILabel()
        description.text = "Please start the navigation as soon as you are on the subway!"
        description.font = UIFont.systemFontOfSize(15.0)
        description.textAlignment = .Center
        description.lineBreakMode = .ByWordWrapping
        description.numberOfLines = 0 //set to display over multiple lines
        description.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton()        
        button.setTitle("Start Navigation", forState: .Normal)
        button.addTarget(self, action:#selector(self.removePauseView), forControlEvents: .TouchUpInside)
        button.sizeToFit()
        button.contentEdgeInsets = UIEdgeInsetsMake(10.0, 15.0, 10.0, 15.0) // add padding
        button.translatesAutoresizingMaskIntoConstraints = false
        
        vibrancyEffectView.contentView.addSubview(title)
        vibrancyEffectView.contentView.addSubview(description)
        vibrancyEffectView.contentView.addSubview(button)
        darkBlurView.contentView.addSubview(vibrancyEffectView)
        
        // add contraints
        // title
        var horizontalConstraint = NSLayoutConstraint(item: title, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: vibrancyEffectView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        vibrancyEffectView.addConstraint(horizontalConstraint)
        
        var verticalConstraint = NSLayoutConstraint(item: title, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: vibrancyEffectView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: -150)
        vibrancyEffectView.addConstraint(verticalConstraint)
        
        // description
        horizontalConstraint = NSLayoutConstraint(item: description, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: vibrancyEffectView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        vibrancyEffectView.addConstraint(horizontalConstraint)
        
        verticalConstraint = NSLayoutConstraint(item: description, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: title, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 100)
        vibrancyEffectView.addConstraint(verticalConstraint)
        
        
        let widthConstraint = NSLayoutConstraint(item: description, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: vibrancyEffectView, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: -50)
        vibrancyEffectView.addConstraint(widthConstraint)
        
        // button
        horizontalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: vibrancyEffectView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
        vibrancyEffectView.addConstraint(horizontalConstraint)
        
        verticalConstraint = NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: description, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 200)
        vibrancyEffectView.addConstraint(verticalConstraint)
        
    }


}

extension NavigationViewController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locationManager did update location")
    }
}

