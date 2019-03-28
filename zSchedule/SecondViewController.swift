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

    // MARK: Properties
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var peopleTextField: UITextField!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeSwitch: UISwitch!
    var selectedDate = Date()
    var time = true
    
    var item: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        titleTextField.delegate = self
        peopleTextField.delegate = self
        timeSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        
        titleTextField.setValue(UIColor.darkGray, forKeyPath: "_placeholderLabel.textColor")
        peopleTextField.setValue(UIColor.darkGray, forKeyPath: "_placeholderLabel.textColor")
        datePicker.setValue(UIColor.white, forKey: "textColor")
        
        /** If editing, populate fields with item details */
        if item != nil {
            titleTextField.text = item?.title
            peopleTextField.text = item?.people
            locationTextView.text = item?.location
            datePicker.date = (item?.date)!
            timeSwitch.setOn((item?.time)!, animated: true)
            
            selectedDate = datePicker.date
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
        newItem.setValue("", forKey: "location")
        newItem.setValue(selectedDate, forKey: "date")
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
    
    /** Change datepicker mode on switch */
    @IBAction func switchToggled(_ sender: UISwitch) {
        time = sender.isOn
        datePicker.datePickerMode = time ? .dateAndTime : .date
    }
    
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === titleTextField
        { titleTextField.text = textField.text }
        
        if textField === peopleTextField
        { peopleTextField.text = textField.text }
    }
}
