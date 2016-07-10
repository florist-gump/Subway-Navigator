//
//  StopSelector.swift
//  SubNav
//
//  Created by Florian Deuerlein on 10/07/2016.
//  Copyright © 2016 Florian Deuerlein. All rights reserved.
//

import UIKit
import PickerView

class StopSelector: UIViewController {
    
    @IBOutlet weak var pickerView:PickerView?
    
    @IBAction func close(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func setNewPickerValue(sender: UIBarButtonItem) {
        if let updateValue = updateSelectedValue, currentSelected = currentSelectedValue {
            updateValue(newSelectedValue: currentSelected)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    var stopNames:[String]?
    var currentSelectedValue: String?
    var updateSelectedValue: ((newSelectedValue: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        pickerView!.dataSource = self
        pickerView!.delegate = self
        pickerView!.selectionStyle = .None
        if let currentSelected = currentSelectedValue, indexOfCurrentSelectedValue = stopNames!.indexOf(currentSelected) {
            pickerView!.currentSelectedRow = indexOfCurrentSelectedValue
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension StopSelector: PickerViewDataSource {
    
    func pickerViewNumberOfRows(pickerView: PickerView) -> Int {
        return stopNames!.count
    }
    
    func pickerView(pickerView: PickerView, titleForRow row: Int, index: Int) -> String {
        return stopNames![index]
    }
    
}

extension StopSelector: PickerViewDelegate {
    func pickerViewHeightForRows(pickerView: PickerView) -> CGFloat {
        return 50.0 // In this example I'm returning arbitrary 50.0pt but you should return the row height you want.
    }
    
    func pickerView(pickerView: PickerView, didSelectRow row: Int, index: Int) {
        currentSelectedValue = stopNames![index]
    }
    
    func pickerView(pickerView: PickerView, styleForLabel label: UILabel, highlighted: Bool) {
        label.textAlignment = .Center
        if (highlighted) {
            label.font = UIFont.systemFontOfSize(26.0, weight: UIFontWeightLight)
        } else {
            label.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightLight)
        }
        
        if (highlighted) {
            label.textColor = view.tintColor
        } else {
            label.textColor = UIColor(red: 161.0/255.0, green: 161.0/255.0, blue: 161.0/255.0, alpha: 1.0)
        }
    }
    
    
}
