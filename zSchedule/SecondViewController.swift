//
//  SecondViewController.swift
//  zSchedule
//
//  Created by Zavid Egbue on 21/03/2019.
//  Copyright © 2019 Zavid. All rights reserved.
//

import UIKit
import CoreData

class SecondViewController: UITableViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var peopleTextField: UITextField!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var timeSwitch: UISwitch!
    @IBOutlet weak var durationSwitch: UISwitch!
    @IBOutlet weak var endDateCell: UITableViewCell!
    
    var selectedDate = Date()
    var selectedEndDate = Date()
    var time = true
    
    var item: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        titleTextField.delegate = self
        peopleTextField.delegate = self
        
        titleTextField.setValue(UIColor.darkGray, forKeyPath: "_placeholderLabel.textColor")
        peopleTextField.setValue(UIColor.darkGray, forKeyPath: "_placeholderLabel.textColor")
        datePicker.setValue(UIColor.white, forKey: "textColor")
        endDatePicker.setValue(UIColor.white, forKey: "textColor")
        
        /** If editing, populate fields with item details */
        if item != nil {
            titleTextField.text = item?.title
            peopleTextField.text = item?.people
            locationTextView.text = item?.location
            datePicker.date = (item?.date)!
            endDatePicker.date = (item?.endDate) ?? Date()
            timeSwitch.setOn((item?.time)!, animated: true)
            
            selectedDate = datePicker.date
            selectedEndDate = durationSwitch.isOn ? endDatePicker.date : Date()
            datePicker.datePickerMode = timeSwitch.isOn ? .dateAndTime : .date
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
        newItem.setValue(locationTextView.text, forKey: "location")
        newItem.setValue(selectedDate, forKey: "date")
        newItem.setValue(selectedEndDate, forKey: "endDate")
        newItem.setValue(time, forKey: "time")
        
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
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if cell === endDateCell && durationSwitch.isOn {
            return 0
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    /** Change datepicker mode on switch */
    @IBAction func dateModeToggled(_ sender: UISwitch) {
        time = sender.isOn
        datePicker.datePickerMode = time ? .dateAndTime : .date
    }
    
    /** Toggle visibility of end datepicker */
    @IBAction func durationToggled(_ sender: UISwitch) {
        endDateCell.isHidden = !sender.isOn
    }
    
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
}
