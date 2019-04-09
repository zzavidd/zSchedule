//
//  SecondViewController.swift
//  zSchedule
//
//  Created by Zavid Egbue on 21/03/2019.
//  Copyright © 2019 Zavid. All rights reserved.
//

import UIKit
import CoreData

class SecondViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var peopleTextField: UITextField!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var startTimeSwitch: UISwitch!
    @IBOutlet weak var endTimeSwitch: UISwitch!
    @IBOutlet weak var durationSwitch: UISwitch!
    @IBOutlet weak var endDateCell: UITableViewCell!
    
    var selectedDate = Date()
    var selectedEndDate = Date()
    var startTime = false
    var endTime = false
    var locationPlaceholderText = "Enter a location..."
    var customColor: UIColor = UIColor.init()
    
    var item: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        /** Store custom textColor for programmtic use */
        customColor = titleTextField.textColor!
        
        titleTextField.delegate = self
        peopleTextField.delegate = self
        locationTextView.delegate = self
        
        /** Set placeholder colors and text */
        titleTextField.setValue(UIColor.darkGray, forKeyPath: "_placeholderLabel.textColor")
        peopleTextField.setValue(UIColor.darkGray, forKeyPath: "_placeholderLabel.textColor")
        locationTextView.text = locationPlaceholderText
        locationTextView.textColor = UIColor.darkGray
        
        datePicker.setValue(UIColor.white, forKey: "textColor")
        endDatePicker.setValue(UIColor.white, forKey: "textColor")
        
        endDatePicker.minimumDate = datePicker.date
        
        /** If editing, populate fields with item details */
        if item != nil {
            titleTextField.text = item?.title
            peopleTextField.text = item?.people
            datePicker.date = (item?.date)!
            endDatePicker.date = (item?.endDate) ?? datePicker.date
    
            if item?.location != "" {
                locationTextView.text = item?.location
                locationTextView.textColor = customColor
            } else {
                locationTextView.text = locationPlaceholderText
                locationTextView.textColor = UIColor.darkGray
            }
            
            startTime = (item?.startTime)!
            startTimeSwitch.setOn(startTime, animated: true)
            
            endTime = (item?.endTime)!
            endTimeSwitch.setOn(endTime, animated: true)
            
            if item?.endDate != nil {
                durationSwitch.setOn(true, animated: true)
                endDateCell.isHidden = false
            }
            
            selectedDate = datePicker.date
            selectedEndDate = endDatePicker.date
            datePicker.datePickerMode = startTimeSwitch.isOn ? .dateAndTime : .date
        }
    }
    
    /** Add new or edit event in CoreData */
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        var newItem: NSManagedObject;
        
        if item == nil {
            /** Adding new task */
            let entity = NSEntityDescription.entity(forEntityName: "Task", in: context)
            newItem = NSManagedObject(entity: entity!, insertInto: context)
        } else {
            /** Editing task */
            newItem = item!.id
        }
        
        newItem.setValue(titleTextField.text, forKey: "title")
        newItem.setValue(peopleTextField!.text, forKey: "people")
        newItem.setValue(!locationTextView.unedited() ? locationTextView.text : "", forKey: "location")
        newItem.setValue(selectedDate, forKey: "date")
        newItem.setValue(durationSwitch.isOn ? selectedEndDate : nil, forKey: "endDate")
        newItem.setValue(startTime, forKey: "startTime")
        
        do {
            try context.save()
            _ = navigationController?.popViewController(animated: true)
        } catch {
            print("Could not save item to schedule.")
        }
    }
    
    /** Return to list of events */
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    /** Store date once selected, change minimum end date */
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        endDatePicker.minimumDate = selectedDate
    }
    
    /** Store end date once selected, change minimum end date */
    @IBAction func endDateChanged(_ sender: UIDatePicker) {
        selectedEndDate = sender.date
    }
    
    /** Customise section header colour */
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    /** Change datepicker mode on switch */
    @IBAction func dateModeToggled(_ sender: UISwitch) {
        startTime = sender.isOn
        datePicker.datePickerMode = startTime ? .dateAndTime : .date
    }
    
    /** Toggle visibility of end datepicker */
    @IBAction func durationToggled(_ sender: UISwitch) {
        endDateCell.isHidden = !sender.isOn
    }
    
    @IBAction func endDateModeToggled(_ sender: UISwitch) {
        endTime = sender.isOn
        endDatePicker.datePickerMode = endTime ? .dateAndTime : .date
    }
    
    /** Hide keyboard off focus */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /** Store text field values */
    func textFieldDidEndEditing(_ sender: UITextField) {
        if sender === titleTextField {
            titleTextField.text = sender.text
        }
        
        if sender === peopleTextField {
            peopleTextField.text = sender.text
        }
    }
    
    /** For location text view placeholder */
    func textViewDidBeginEditing(_ textView: UITextView) {
        if locationTextView.unedited() {
            locationTextView.text = ""
            locationTextView.textColor = customColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if locationTextView.text.isEmpty {
            locationTextView.text = locationPlaceholderText
            locationTextView.textColor = UIColor.darkGray
        }
    }
}

extension UITextView {
    func unedited() -> Bool {
        return self.textColor == UIColor.darkGray
    }
}
