//
//  SecondViewController.swift
//  zSchedule
//
//  Created by Zavid Egbue on 21/03/2019.
//  Copyright © 2019 Zavid. All rights reserved.
//

import UIKit
import CoreData

class SecondViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var peopleTextField: UITextField!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    var selectedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        titleTextField.delegate = self
        peopleTextField.delegate = self
        
        datePicker.setValue(UIColor.white, forKey: "textColor")
    }
    
    // MARK: Actions
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
    
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: context)
    
        let newItem = NSManagedObject(entity: entity!, insertInto: context)
        
        newItem.setValue(titleTextField.text, forKey: "title")
        newItem.setValue(peopleTextField!.text, forKey: "people")
        newItem.setValue("", forKey: "location")
        newItem.setValue(selectedDate, forKey: "date")
        
        do {
            try context.save()
             _ = navigationController?.popViewController(animated: true)
        } catch {
            print("Could not save item to schedule.")
        }
        
        
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
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
