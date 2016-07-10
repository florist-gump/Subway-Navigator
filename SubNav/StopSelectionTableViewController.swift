//
//  StopSelectionTableViewController.swift
//  SubNav
//
//  Created by Florian Deuerlein on 10/07/2016.
//  Copyright © 2016 Florian Deuerlein. All rights reserved.
//

import UIKit
import SwiftCSV

class StopSelectionTableViewController: UITableViewController {
    @IBOutlet weak var line: UISegmentedControl!
    @IBOutlet weak var originLabel:UILabel?
    @IBOutlet weak var destinationLabel:UILabel?
    
    @IBAction func startNavigation(x:UIButton) {
        if pickedOrigin == nil || pickedDestination == nil {
            let stopAlert = UIAlertController(title: "Stops not selected", message: "Please make sure you selected a origion and destination stop", preferredStyle: UIAlertControllerStyle.Alert)
            
            stopAlert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: { (action: UIAlertAction!) in
                
            }))
            
            presentViewController(stopAlert, animated: true, completion: nil)
        } else {
            performSegueWithIdentifier("Navigate", sender: nil)
        }

    }
    
    @IBAction func changeLine(x:UISegmentedControl) {
        stopNames = stopNames!.reverse()
    }
    
    var pickedOrigin: String?
    var pickedDestination: String?
    
    var stops:CSV?
    var stopNames:[String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Select"
        let fileLocation = NSBundle.mainBundle().pathForResource("stops", ofType: "csv")!
        do {
            stops = try CSV(name: fileLocation)
            stopNames = stops?.columns["stopname"]
        } catch {
            print("error reading csv ")
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SelectOriginStop" || segue.identifier == "SelectDestinationStop" {
            let Nav = segue.destinationViewController as! UINavigationController
            let stopSelector = Nav.topViewController as! StopSelector
            stopSelector.stopNames = stopNames
            
            if segue.identifier == "SelectOriginStop" {
                stopSelector.currentSelectedValue = pickedOrigin
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
            let origin = stopNames!.indexOf(pickedOrigin!)
            let dest = stopNames!.indexOf(pickedDestination!)
            let stopNameSelection = stopNames![origin!...dest!]
            
            navController.stops = Array(stopNameSelection)
            navController.currentStop = navController.stops.count/2
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