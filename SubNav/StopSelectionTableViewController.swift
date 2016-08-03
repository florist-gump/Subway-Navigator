//
//  StopSelectionTableViewController.swift
//  SubNav
//
//  Created by Florian Deuerlein on 10/07/2016.
//  Copyright © 2016 Florian Deuerlein. All rights reserved.
//

import UIKit

class StopSelectionTableViewController: UITableViewController {
    @IBOutlet weak var originLabel:UILabel?
    @IBOutlet weak var destinationLabel:UILabel?
    
    @IBAction func startNavigation(x:UIButton) {
        if pickedOrigin == nil || pickedDestination == nil  || pickedOrigin == pickedDestination {
            let stopAlert = UIAlertController(title: "Stops not selected", message: "Please make sure you selected valid origin and destination stops", preferredStyle: UIAlertControllerStyle.Alert)
            
            stopAlert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (action: UIAlertAction!) in
                
            }))
            
            presentViewController(stopAlert, animated: true, completion: nil)
        } else {
            performSegueWithIdentifier("Navigate", sender: nil)
        }
    }
    
    @IBAction func changeLine(segmentedControl:UISegmentedControl) {
        if segmentedControl.selectedSegmentIndex == 0 {
            line.changeLine("in")
        } else {
            line.changeLine("out")
        }
        stopNames = self.line.stopNames()
    }
    
    var pickedOrigin: String?
    var pickedDestination: String?
    
    var stopNames:[String]?
    var line:Line!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select"
        line = Line(line: "out")
        stopNames = line.stopNames()
        //tmp
        pickedOrigin = "Kelvinbridge"
        pickedDestination = "Partick"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SelectOriginStop" || segue.identifier == "SelectDestinationStop" {
            let Nav = segue.destinationViewController as! UINavigationController
            let stopSelector = Nav.topViewController as! StopSelector
            stopSelector.stopNames = stopNames
            
            if segue.identifier == "SelectOriginStop" {
                if (pickedOrigin != nil) {
                    stopSelector.currentSelectedValue = pickedOrigin
                } else {
                    stopSelector.currentSelectedValue = stopNames![0]
                }
                stopSelector.updateSelectedValue = { (newSelectedValue) in
                    self.pickedOrigin = newSelectedValue
                    self.originLabel!.text = self.pickedOrigin
                    self.tableView.reloadData()
                }
            }
            if segue.identifier == "SelectDestinationStop" {
                stopSelector.currentSelectedValue = pickedDestination
                if pickedDestination == nil && pickedOrigin != nil {
                    stopSelector.currentSelectedValue = pickedOrigin
                }
                stopSelector.updateSelectedValue = { (newSelectedValue) in
                    self.pickedDestination = newSelectedValue
                    self.destinationLabel!.text = self.pickedDestination
                    self.tableView.reloadData()
                }
            }
        }
        if segue.identifier == "Navigate" {
            let navController = segue.destinationViewController as! NavigationViewController
            let stopsBetween = line.stopsBetween(pickedOrigin!, destination: pickedDestination!)
            navController.stops = stopsBetween
        }

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 1:
            performSegueWithIdentifier("SelectOriginStop", sender: nil)
        case 2:
            performSegueWithIdentifier("SelectDestinationStop", sender: nil)
        default:
            break
        }
    }

}