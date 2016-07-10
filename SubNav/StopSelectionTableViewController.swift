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
        performSegueWithIdentifier("Navigate", sender: nil)
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
            stopSelector.updateSelectedValue = { (newSelectedValue) in
                self.pickedDestination = newSelectedValue
                self.destinationLabel!.text = self.pickedDestination
                self.tableView.reloadData()
            }
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